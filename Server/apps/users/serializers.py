from rest_framework import serializers
from django.contrib.auth import get_user_model
from apps.community.models import GhostProfile

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'role', 'display_name', 'license_id', 'specialty', 'verified_at', 'is_online']
        read_only_fields = ['id', 'role', 'verified_at', 'is_online'] # Role set at registration

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    role = serializers.ChoiceField(choices=User.Role.choices, default=User.Role.PATIENT)

    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'role', 'first_name', 'last_name', 'license_id', 'specialty']

    def create(self, validated_data):
        password = validated_data.pop('password')
        role = validated_data.get('role', User.Role.PATIENT)
        
        # Security check: Only admins can create admins via API? or simpler:
        if role == User.Role.ADMIN:
             role = User.Role.PATIENT # Force downgrade if tried via public API
        
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        
        # Create Ghost Profile for every user automatically
        GhostProfile.objects.create(
            user=user,
            display_name=f"Anonymous {user.username[:3]}", # Default
            is_active=True
        )
        
        return user
