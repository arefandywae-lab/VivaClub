from rest_framework import serializers
from .models import GhostProfile, GhostSubscription, Room, Notification, UserTrustScore, RoomReport, BlockedUser

class GhostProfileSerializer(serializers.ModelSerializer):
    role = serializers.CharField(source='user.role', read_only=True)

    class Meta:
        model = GhostProfile
        fields = ['id', 'display_name', 'avatar_url', 'bio', 'followers_count', 'is_active', 'role']
        read_only_fields = ['id', 'followers_count', 'role']

    def validate_display_name(self, value):
        # Optional: Add profanity filter here
        return value

class GhostSubscriptionSerializer(serializers.ModelSerializer):
    target_details = GhostProfileSerializer(source='target', read_only=True)
    followed_at = serializers.DateTimeField(source='created_at', read_only=True)
    
    class Meta:
        model = GhostSubscription
        fields = ['id', 'follower', 'target', 'target_details', 'followed_at', 'created_at']
        read_only_fields = ['id', 'follower', 'created_at']

class RoomSerializer(serializers.ModelSerializer):
    host_details = GhostProfileSerializer(source='host', read_only=True)
    
    class Meta:
        model = Room
        fields = [
            'id', 'title', 'host', 'host_details', 'category',
            'description', 'tags', 'scheduled_at', 'is_scheduled',
            'trending_score', 'peak_listeners',
            'listeners_count', 'last_active_at', 'is_active', 'created_at'
        ]
        read_only_fields = [
            'id', 'host', 'listeners_count', 'trending_score',
            'peak_listeners', 'last_active_at', 'is_active', 'created_at'
        ]

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'type', 'title', 'body', 'data', 'is_read', 'created_at']
        read_only_fields = ['id', 'created_at']

class UserTrustScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserTrustScore
        fields = ['score', 'total_reports_received', 'valid_reports_received', 'total_reports_made', 'last_updated']
        read_only_fields = ['score', 'total_reports_received', 'valid_reports_received', 'total_reports_made', 'last_updated']

class RoomReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomReport
        fields = ['id', 'reporter', 'reported_user', 'room', 'reason', 'description', 'status', 'created_at']
        read_only_fields = ['id', 'reporter', 'status', 'created_at']

class BlockedUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlockedUser
        fields = ['id', 'blocked', 'created_at']
        read_only_fields = ['id', 'blocker', 'created_at']
