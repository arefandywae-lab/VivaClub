from rest_framework import viewsets, permissions, decorators, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import GhostProfile, GhostSubscription, Room
from .serializers import GhostProfileSerializer, GhostSubscriptionSerializer, RoomSerializer
from apps.utils.ghost_names import generate_ghost_name
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
            
        serializer.save(host=host_profile, title=title)

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

        # Update room occupant tracking
        from django.utils import timezone
        room.listeners_count += 1
        room.last_active_at = timezone.now()
        room.save()

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
        
        # Decrement count (don't go below 0)
        room.listeners_count = max(0, room.listeners_count - 1)
        
        # If room is now empty, mark the time it became empty
        if room.listeners_count == 0:
            room.last_active_at = timezone.now()
        
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
            svc = api.RoomServiceClient(ws_url, api_key, api_secret)
            # Grant can_publish=True
            svc.update_participant_permissions(
                room=str(room.id),
                identity=target_identity,
                permission=api.ParticipantPermission(
                    can_subscribe=True,
                    can_publish=True,
                    can_publish_data=True,
                ),
            )
            return Response({"message": "Invited speaker successfully"})
        except Exception as e:
            return Response({"error": str(e)}, status=500)

