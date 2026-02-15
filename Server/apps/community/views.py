from rest_framework import viewsets, permissions, decorators, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from .models import GhostProfile, GhostSubscription, Room, Notification, FCMToken
from .serializers import (
    GhostProfileSerializer, 
    GhostSubscriptionSerializer, 
    RoomSerializer,
    NotificationSerializer
)
from apps.utils.ghost_names import generate_ghost_name
from .services import NotificationService
import uuid

# ... GhostProfileViewSet ...
class GhostProfileViewSet(viewsets.ModelViewSet):
    queryset = GhostProfile.objects.filter(is_active=True)
    serializer_class = GhostProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    @decorators.action(detail=False, methods=['get', 'put', 'patch'], url_path='me')
    def me(self, request):
        """Get or update own ghost profile"""
        # Ensure ghost profile exists
        profile, created = GhostProfile.objects.get_or_create(
            user=request.user, 
            defaults={'display_name': generate_ghost_name()}
        )
        
        if request.method == 'GET':
            serializer = self.get_serializer(profile)
            return Response(serializer.data)
        
        serializer = self.get_serializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    @decorators.action(detail=True, methods=['post'], url_path='follow')
    def follow(self, request, pk=None):
        target_profile = self.get_object()
        my_profile = get_object_or_404(GhostProfile, user=request.user)
        
        if target_profile == my_profile:
             return Response({"error": "Cannot follow yourself."}, status=400)
             
        # Create subscription
        if not GhostSubscription.objects.filter(follower=my_profile, target=target_profile).exists():
            GhostSubscription.objects.create(follower=my_profile, target=target_profile)
            # Increment count
            target_profile.followers_count += 1
            target_profile.save()
            return Response({"message": f"Now following {target_profile.display_name}"})
            
        return Response({"message": "Already following."}, status=200)

    @decorators.action(detail=True, methods=['post'], url_path='unfollow')
    def unfollow(self, request, pk=None):
        target_profile = self.get_object()
        my_profile = get_object_or_404(GhostProfile, user=request.user)
        
        deleted, _ = GhostSubscription.objects.filter(follower=my_profile, target=target_profile).delete()
        if deleted:
            target_profile.followers_count = max(0, target_profile.followers_count - 1)
            target_profile.save()
            
        return Response({"message": f"Unfollowed {target_profile.display_name}"})

class GhostSubscriptionViewSet(viewsets.ReadOnlyModelViewSet):
    """List who I am following"""
    serializer_class = GhostSubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        my_profile = get_object_or_404(GhostProfile, user=self.request.user)
        return GhostSubscription.objects.filter(follower=my_profile)
    
    @decorators.action(detail=False, methods=['get'], url_path='feed')
    def feed(self, request):
        """Get active rooms from followed ghosts"""
        my_profile = get_object_or_404(GhostProfile, user=request.user)
        
        # Get IDs of ghosts I'm following
        following_ids = GhostSubscription.objects.filter(
            follower=my_profile
        ).values_list('target_id', flat=True)
        
        # Get active rooms from followed ghosts
        rooms = Room.objects.filter(
            host_id__in=following_ids,
            is_active=True
        ).select_related('host').order_by('-created_at')
        
        serializer = RoomSerializer(rooms, many=True)
        
        return Response({
            'rooms': serializer.data,
            'count': rooms.count()
        })

class RoomViewSet(viewsets.ModelViewSet):
    """
    CRUD for Clubhouse Rooms.
    - POST /: Create a new room (User automatically becomes Speaker/Host)
    - GET /: List active rooms
    - POST /{id}/join: Get LiveKit Token to join as Listener
    """
    serializer_class = RoomSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # 1. Proactive cleanup: deactivate empty rooms older than 1 minute
        from django.utils import timezone
        from datetime import timedelta
        one_minute_ago = timezone.now() - timedelta(minutes=1)
        
        Room.objects.filter(
            is_active=True,
            listeners_count=0,
            last_active_at__lte=one_minute_ago
        ).update(is_active=False)
        
        # 2. Return active rooms
        return Room.objects.filter(is_active=True).order_by('-created_at')

    def perform_create(self, serializer):
        # Auto-assign host from request.user's GhostProfile
        host_profile, _ = GhostProfile.objects.get_or_create(
            user=self.request.user,
            defaults={'display_name': generate_ghost_name()}
        )
        
        # Unique Title Logic
        title = serializer.validated_data.get('title', 'Untitled Room')
        original_title = title
        counter = 1
        
        # Check if active room with this title exists
        while Room.objects.filter(title=title, is_active=True).exists():
            title = f"{original_title}#{counter}"
            counter += 1
            
        room = serializer.save(host=host_profile, title=title)
        
        # Send notifications to followers
        NotificationService.send_ghost_room_notification(
            ghost_id=host_profile.id,
            room_id=room.id,
            room_title=room.title
        )

    @decorators.action(detail=True, methods=['post'], url_path='join')
    def join(self, request, pk=None):
        room = self.get_object()
        
        # 1. Get User's Ghost Profile
        user_profile, _ = GhostProfile.objects.get_or_create(
            user=request.user,
            defaults={'display_name': generate_ghost_name()}
        )

        # 2. Determine Role
        # If user is host -> Speaker/Admin
        is_host = (room.host == user_profile)
        
        # 3. Generate LiveKit Token
        from livekit import api
        import os
        
        api_key = os.environ.get('LIVEKIT_API_KEY')
        api_secret = os.environ.get('LIVEKIT_API_SECRET')
        ws_url = os.environ.get('LIVEKIT_API_URL')

        if not api_key or not api_secret:
             return Response({"error": "LiveKit credentials not configured"}, status=500)

        # Identity = User ID (Ghost Profile ID for anonymity in room?)
        # Let's use User ID for persistence, but display name from Ghost
        identity = str(request.user.id)
        name = user_profile.display_name

        grant = api.VideoGrants(
            room_join=True,
            room=str(room.id),
            can_publish=is_host, # Only host can speak initially
            can_subscribe=True,
            can_publish_data=True, # Allow chat
            can_update_own_metadata=True, # Allow hand-raise
        )

        # Metadata: {"role": "doctor"} or {"role": "patient"}
        import json
        metadata = json.dumps({'role': request.user.role})

        token = api.AccessToken(api_key, api_secret) \
            .with_identity(identity) \
            .with_name(name) \
            .with_grants(grant) \
            .with_metadata(metadata) \
            .to_jwt()

        # Update room occupant tracking (atomic to prevent race conditions)
        from django.utils import timezone
        from django.db.models import F
        from django.db import transaction
        
        with transaction.atomic():
            Room.objects.filter(id=room.id).update(
                listeners_count=F('listeners_count') + 1,
                last_active_at=timezone.now()
            )
            room.refresh_from_db()  # Get updated values

        return Response({
            "token": token,
            "url": ws_url,
            "room_id": str(room.id),
            "is_host": is_host,
            "identity": identity
        })

    @decorators.action(detail=True, methods=['post'], url_path='leave')
    def leave(self, request, pk=None):
        room = self.get_object()
        from django.utils import timezone
        
        # Decrement count (atomic to prevent race conditions)
        from django.db.models import F, Q
        from django.db import transaction
        
        with transaction.atomic():
            # Use F() expression with conditional to prevent going below 0
            Room.objects.filter(id=room.id).update(
                listeners_count=F('listeners_count') - 1,
                last_active_at=timezone.now()
            )
            room.refresh_from_db()
            
            # Ensure count doesn't go below 0
            if room.listeners_count < 0:
                room.listeners_count = 0
                room.save()
        return Response({"message": "Left room"})
        
    @decorators.action(detail=True, methods=['post'], url_path='invite')
    def invite(self, request, pk=None):
        room = self.get_object()
        
        # 1. Verify Host
        user_profile, _ = GhostProfile.objects.get_or_create(user=request.user)
        if room.host != user_profile:
             return Response({"error": "Only host can invite speakers"}, status=403)

        target_identity = request.data.get('identity')
        if not target_identity:
             return Response({"error": "Target identity required"}, status=400)

        # 2. Update Permissions via LiveKit Server API
        from livekit import api
        import os
        
        api_key = os.environ.get('LIVEKIT_API_KEY')
        api_secret = os.environ.get('LIVEKIT_API_SECRET')
        ws_url = os.environ.get('LIVEKIT_API_URL')

        if not api_key or not api_secret:
             return Response({"error": "LiveKit credentials not configured"}, status=500)

        try:
            from asgiref.sync import async_to_sync
            from livekit.api.twirp_client import TwirpError

            async def invite_speaker_async():
                lkapi = api.LiveKitAPI(ws_url, api_key, api_secret)
                try:
                    # Correct usage: pass a single request object
                    request_obj = api.UpdateParticipantRequest(
                        room=str(room.id),
                        identity=target_identity,
                        permission=api.ParticipantPermission(
                            can_subscribe=True,
                            can_publish=True,
                            can_publish_data=True,
                        )
                    )
                    
                    await lkapi.room.update_participant(request_obj)
                    return None # Success
                
                except TwirpError as e:
                    # Handle known business logic errors (user not found in room)
                    if str(e.code) == 'not_found' or str(e.code) == 'TwirpErrorCode.NOT_FOUND':
                        return Response({"error": "User is not active in this room (must join first)"}, status=404)
                    raise e
                finally:
                    await lkapi.aclose()

            # Execute and check result
            # Execute and check result
            result = async_to_sync(invite_speaker_async)()
            if isinstance(result, Response):
                return result
            
            return Response({"message": "Invited speaker successfully"})
        except Exception as e:
            import traceback
            traceback.print_exc()
            return Response({"error": str(e)}, status=500)
    
    @decorators.action(detail=True, methods=['post'], url_path='mute-participant')
    def mute_participant(self, request, pk=None):
        """Mute a participant (Host only)"""
        room = self.get_object()
        
        # Verify Host
        user_profile, _ = GhostProfile.objects.get_or_create(user=request.user)
        if room.host != user_profile:
             return Response({"error": "Only host can mute participants"}, status=403)

        target_identity = request.data.get('identity')
        track_sid = request.data.get('track_sid')
        muted = request.data.get('muted', True)

        if not target_identity or not track_sid:
             return Response({"error": "Target identity and track_sid required"}, status=400)

        # LiveKit API
        from livekit import api
        from livekit.api.twirp_client import TwirpError
        import os
        
        api_key = os.environ.get('LIVEKIT_API_KEY')
        api_secret = os.environ.get('LIVEKIT_API_SECRET')
        ws_url = os.environ.get('LIVEKIT_API_URL')
        
        try:
            from asgiref.sync import async_to_sync
            async def mute_async():
                lkapi = api.LiveKitAPI(ws_url, api_key, api_secret)
                try:
                    request_obj = api.MuteRoomTrackRequest(
                        room=str(room.id),
                        identity=target_identity,
                        track_sid=track_sid,
                        muted=muted
                    )
                    await lkapi.room.mute_published_track(request_obj)
                except TwirpError as e:
                    if str(e.code) == 'not_found':
                        return Response({"error": "Participant or track not found"}, status=404)
                    raise e
                finally:
                    await lkapi.aclose()

            result = async_to_sync(mute_async)()
            if isinstance(result, Response): return result
            
            return Response({"message": "Participant muted successfully"})
        except Exception as e:
            return Response({"error": str(e)}, status=500)

    @decorators.action(detail=True, methods=['post'], url_path='kick-participant')
    def kick_participant(self, request, pk=None):
        """Kick a participant from the room (Host only)"""
        room = self.get_object()
        
        # Verify Host
        user_profile, _ = GhostProfile.objects.get_or_create(user=request.user)
        if room.host != user_profile:
             return Response({"error": "Only host can kick participants"}, status=403)

        target_identity = request.data.get('identity')
        if not target_identity:
             return Response({"error": "Target identity required"}, status=400)

        # LiveKit API
        from livekit import api
        from livekit.api.twirp_client import TwirpError
        import os
        
        api_key = os.environ.get('LIVEKIT_API_KEY')
        api_secret = os.environ.get('LIVEKIT_API_SECRET')
        ws_url = os.environ.get('LIVEKIT_API_URL')
        
        try:
            from asgiref.sync import async_to_sync
            async def kick_async():
                lkapi = api.LiveKitAPI(ws_url, api_key, api_secret)
                try:
                    # Use semantic request object: RoomParticipantIdentity is used for RemoveParticipant
                    request_obj = api.RoomParticipantIdentity(
                        room=str(room.id),
                        identity=target_identity
                    )
                    await lkapi.room.remove_participant(request_obj)
                except TwirpError as e:
                    if str(e.code) == 'not_found':
                        return Response({"error": "Participant not found"}, status=404)
                    raise e
                finally:
                    await lkapi.aclose()

            result = async_to_sync(kick_async)()
            if isinstance(result, Response): return result
            
            return Response({"message": "Participant kicked successfully"})
        except Exception as e:
            return Response({"error": str(e)}, status=500)
    
    @decorators.action(detail=False, methods=['get'], url_path='trending')
    def trending(self, request):
        """Get trending rooms sorted by trending score"""
        from django.utils import timezone
        
        category = request.query_params.get('category')
        limit = int(request.query_params.get('limit', 10))
        
        # Calculate trending score for active rooms
        now = timezone.now()
        rooms = Room.objects.filter(is_active=True)
        
        if category and category != 'general':
            rooms = rooms.filter(category=category)
        
        # Calculate trending score
        for room in rooms:
            minutes_old = (now - room.created_at).total_seconds() / 60
            age_penalty = max(0, 100 - (minutes_old * 2))
            room.trending_score = (room.listeners_count * 10) + age_penalty
            room.save(update_fields=['trending_score'])
        
        # Get top trending
        trending_rooms = rooms.order_by('-trending_score')[:limit]
        serializer = RoomSerializer(trending_rooms, many=True)
        
        return Response({'rooms': serializer.data})
    
    @decorators.action(detail=False, methods=['get'], url_path='scheduled')
    def scheduled(self, request):
        """Get scheduled rooms"""
        from django.utils import timezone
        
        upcoming = request.query_params.get('upcoming', 'true') == 'true'
        
        rooms = Room.objects.filter(is_scheduled=True)
        
        if upcoming:
            rooms = rooms.filter(scheduled_at__gte=timezone.now())
        
        rooms = rooms.order_by('scheduled_at')
        serializer = RoomSerializer(rooms, many=True)
        
        return Response({'rooms': serializer.data})
    
    @decorators.action(detail=False, methods=['get'], url_path='search')
    def search(self, request):
        """Search rooms by title, description, tags"""
        from django.db.models import Q
        
        query = request.query_params.get('q', '').strip()
        category = request.query_params.get('category')
        
        if not query:
            return Response({'rooms': [], 'count': 0})
        
        # Search in title, description, tags
        rooms = Room.objects.filter(
            Q(title__icontains=query) |
            Q(description__icontains=query) |
            Q(tags__icontains=query),
            is_active=True
        )
        
        if category and category != 'general':
            rooms = rooms.filter(category=category)
        
        serializer = RoomSerializer(rooms, many=True)
        
        return Response({
            'rooms': serializer.data,
            'count': rooms.count()
        })


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """List and manage user notifications"""
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)
    
    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        
        unread_count = queryset.filter(is_read=False).count()
        
        return Response({
            'notifications': serializer.data,
            'unread_count': unread_count
        })
    
    @decorators.action(detail=True, methods=['post'], url_path='read')
    def mark_read(self, request, pk=None):
        """Mark notification as read"""
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'success': True})
    
    @decorators.action(detail=False, methods=['post'], url_path='read-all')
    def mark_all_read(self, request):
        """Mark all notifications as read"""
        self.get_queryset().update(is_read=True)
        return Response({'success': True})


class FCMTokenView(APIView):
    """Register FCM token for push notifications"""
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        token = request.data.get('token')
        
        if not token:
            return Response({'error': 'Token required'}, status=400)
        
        # Create or update FCM token
        fcm_token, created = FCMToken.objects.update_or_create(
            user=request.user,
            defaults={'token': token}
        )
        
        return Response({
            'success': True,
            'message': 'FCM token registered' if created else 'FCM token updated'
        })
