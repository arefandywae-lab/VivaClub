from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404, render
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.conf import settings
import uuid
from .serializers import RegisterSerializer, UserSerializer, ForgotPasswordSerializer, ResetPasswordSerializer

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

    def perform_create(self, serializer):
        user = serializer.save()
        # Generate verification token
        token = get_random_string(64)
        user.email_verification_token = token
        user.save()
        
        # Send Verification Email
        try:
            send_mail(
                'Verify your VivaClub Email',
                f'Welcome to VivaClub! Please verify your email by clicking: https://vivaclubs.site/api/auth/verify-email/?token={token}',
                settings.DEFAULT_FROM_EMAIL,
                [user.email],
                fail_silently=True,
            )
        except Exception as e:
            print(f"Failed to send email: {e}")

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

class AdminTestPushView(APIView):
    """Admin only API to send a test broadcast push notification"""
    permission_classes = (permissions.IsAuthenticated, permissions.IsAdminUser)

    def post(self, request):
        from apps.utils.notifications import broadcast_test_push
        count = broadcast_test_push()
        return Response({
            "message": f"Test notification sent to {count} devices",
            "success_count": count
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

class ForgotPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            user = User.objects.filter(email=email).first()
            if user:
                token = uuid.uuid4().hex
                user.email_verification_token = token
                user.save()
                
                reset_link = f"https://vivaclubs.site/api/auth/reset-password-page/?token={token}"
                subject = "VivaClub - Password Reset Request"
                message = f"You requested a password reset. Please use the link below to create a new password:\n\n{reset_link}\n\nIf you did not request this, please ignore this email."
                
                try:
                    send_mail(
                        subject,
                        message,
                        settings.DEFAULT_FROM_EMAIL,
                        [email],
                        fail_silently=False,
                    )
                except Exception as e:
                    return Response({"error": f"Failed to send email: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
            return Response({"message": "If an account with that email exists, a reset link has been sent."}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ResetPasswordPageView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        token = request.query_params.get('token')
        return render(request, 'reset_password.html', {'token': token})

class ResetPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            token = serializer.validated_data['token']
            new_password = serializer.validated_data['new_password']
            user = User.objects.filter(email_verification_token=token).first()
            if user:
                user.set_password(new_password)
                user.email_verification_token = None
                user.save()
                return Response({"message": "Password reset successfully"})
            return Response({"error": "Invalid or expired token"}, status=400)
        return Response(serializer.errors, status=400)

class VerifyEmailView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        token = request.query_params.get('token')
        user = User.objects.filter(email_verification_token=token).first()
        if user:
            user.is_email_verified = True
            user.email_verification_token = None
            user.save()
            return Response({"message": "Email verified successfully. You can now login."})
        return Response({"error": "Invalid or expired token"}, status=400)


