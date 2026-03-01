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

