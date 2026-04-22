from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from .serializers import RegisterSerializer, UserSerializer

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

class ProfileView(generics.RetrieveUpdateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.IsAuthenticated,)
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


class AdminUserListView(generics.ListAPIView):
    """Admin only API to list all users"""
    queryset = User.objects.all().order_by('-date_joined')
    permission_classes = (permissions.IsAuthenticated, permissions.IsAdminUser)
    serializer_class = UserSerializer


class AdminUserActionView(APIView):
    """Admin actions: ban, unban, promote, demote a user"""
    permission_classes = (permissions.IsAuthenticated, permissions.IsAdminUser)

    def post(self, request, pk, action):
        user = get_object_or_404(User, pk=pk)

        # Prevent admin from modifying themselves
        if user == request.user:
            return Response({"error": "Cannot modify your own account"}, status=400)

        if action == 'ban':
            user.is_active = False
            user.save()
            return Response({"message": f"User {user.username} has been banned"})
        elif action == 'unban':
            user.is_active = True
            user.save()
            return Response({"message": f"User {user.username} has been unbanned"})
        elif action == 'promote':
            user.is_staff = True
            user.role = 'admin'
            user.save()
            return Response({"message": f"User {user.username} promoted to admin"})
        elif action == 'demote':
            user.is_staff = False
            user.role = 'patient'
            user.save()
            return Response({"message": f"User {user.username} demoted to patient"})
        else:
            return Response({"error": "Invalid action"}, status=400)


class AdminCleanupTestDataView(APIView):
    """Delete all test rooms and test users created by stress tests"""
    permission_classes = (permissions.IsAuthenticated, permissions.IsAdminUser)

    def post(self, request):
        from apps.community.models import Room, GhostProfile
        from django.db.models import Q

        # Delete test rooms (title starts with "Test Room #" or "Test Anxiety" or "test")
        test_rooms = Room.objects.filter(
            Q(title__startswith='Test Room #') |
            Q(title__startswith='Test Anxiety') |
            Q(title='test')
        )
        rooms_count = test_rooms.count()
        test_rooms.delete()

        # Delete test users (username starts with "clubhouse_user_" or "testuser_")
        test_users = User.objects.filter(
            Q(username__startswith='clubhouse_user_') |
            Q(username__startswith='testuser_')
        )
        users_count = test_users.count()

        # Delete their ghost profiles first
        ghost_profiles = GhostProfile.objects.filter(user__in=test_users)
        ghosts_count = ghost_profiles.count()
        ghost_profiles.delete()

        test_users.delete()

        return Response({
            "message": "Test data cleaned up successfully",
            "deleted_rooms": rooms_count,
            "deleted_users": users_count,
            "deleted_ghost_profiles": ghosts_count,
        })

from rest_framework import viewsets
from .models import DeviceToken
from .serializers import DeviceTokenSerializer

class DeviceTokenViewSet(viewsets.ModelViewSet):
    serializer_class = DeviceTokenSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DeviceToken.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Update if token already exists for another user (theft prevention or device handoff)
        token = self.request.data.get('token')
        DeviceToken.objects.filter(token=token).delete()
        serializer.save(user=self.request.user)


