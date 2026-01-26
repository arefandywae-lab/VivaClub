from rest_framework import viewsets, permissions, decorators, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import GhostProfile, GhostSubscription
from .serializers import GhostProfileSerializer, GhostSubscriptionSerializer

class GhostProfileViewSet(viewsets.ModelViewSet):
    queryset = GhostProfile.objects.filter(is_active=True)
    serializer_class = GhostProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    @decorators.action(detail=False, methods=['get', 'put', 'patch'], url_path='me')
    def me(self, request):
        """Get or update own ghost profile"""
        profile = get_object_or_404(GhostProfile, user=request.user)
        
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
