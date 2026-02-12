from rest_framework import serializers
from .models import GhostProfile, GhostSubscription, Room

class GhostProfileSerializer(serializers.ModelSerializer):
    role = serializers.CharField(source='user.role', read_only=True)

    class Meta:
        model = GhostProfile
        fields = ['id', 'display_name', 'avatar_url', 'followers_count', 'is_active', 'role']
        read_only_fields = ['id', 'followers_count', 'role']

    def validate_display_name(self, value):
        # Optional: Add profanity filter here
        return value

class GhostSubscriptionSerializer(serializers.ModelSerializer):
    target_details = GhostProfileSerializer(source='target', read_only=True)
    
    class Meta:
        model = GhostSubscription
        fields = ['id', 'follower', 'target', 'target_details', 'created_at']
        read_only_fields = ['id', 'follower', 'created_at']

class RoomSerializer(serializers.ModelSerializer):
    host_details = GhostProfileSerializer(source='host', read_only=True)
    
    class Meta:
        model = Room
        fields = ['id', 'title', 'host', 'host_details', 'category', 'listeners_count', 'last_active_at', 'is_active', 'created_at']
        read_only_fields = ['id', 'host', 'listeners_count', 'last_active_at', 'is_active', 'created_at']
