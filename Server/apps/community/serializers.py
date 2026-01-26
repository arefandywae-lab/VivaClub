from rest_framework import serializers
from .models import GhostProfile, GhostSubscription

class GhostProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = GhostProfile
        fields = ['id', 'display_name', 'avatar_url', 'followers_count', 'is_active']
        read_only_fields = ['id', 'followers_count']

    def validate_display_name(self, value):
        # Optional: Add profanity filter here
        return value

class GhostSubscriptionSerializer(serializers.ModelSerializer):
    target_details = GhostProfileSerializer(source='target', read_only=True)
    
    class Meta:
        model = GhostSubscription
        fields = ['id', 'follower', 'target', 'target_details', 'created_at']
        read_only_fields = ['id', 'follower', 'created_at']
