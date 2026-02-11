from rest_framework import serializers
from django.contrib.auth import get_user_model
from apps.community.models import GhostProfile

User = get_user_model()

from apps.utils.ghost_names import generate_ghost_name

class UserSerializer(serializers.ModelSerializer):
    ghost_profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone_number', 'role', 'display_name', 'license_id', 'specialty', 'verified_at', 'is_online', 'ghost_profile']
        read_only_fields = ['id', 'role', 'verified_at', 'is_online', 'ghost_profile']

    def get_ghost_profile(self, obj):
        # Return simple ghost profile info
        if hasattr(obj, 'ghost_profile'):
             return {
                 'display_name': obj.ghost_profile.display_name,
                 'avatar': obj.ghost_profile.avatar_url # Ensure model has this or handle None
             }
        return None

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    role = serializers.ChoiceField(choices=User.Role.choices, default=User.Role.PATIENT)

    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'phone_number', 'role', 'first_name', 'last_name', 'license_id', 'specialty']

    def create(self, validated_data):
        password = validated_data.pop('password')
        role = validated_data.get('role', User.Role.PATIENT)
        
        # Security check
        if role == User.Role.ADMIN:
             role = User.Role.PATIENT 
        
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        
        # Create Ghost Profile with random name
        GhostProfile.objects.create(
            user=user,
            display_name=generate_ghost_name(),
            is_active=True
        )
        
        return user
