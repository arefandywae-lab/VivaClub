from rest_framework import serializers
from django.contrib.auth import get_user_model
from apps.community.models import GhostProfile

User = get_user_model()

from apps.utils.ghost_names import generate_ghost_name

from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data['user_id'] = self.user.id
        data['role'] = self.user.role
        data['display_name'] = self.user.display_name or self.user.username
        data['is_staff'] = self.user.is_staff
        return data

class UserSerializer(serializers.ModelSerializer):
    ghost_profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'phone_number', 'role', 
            'display_name', 'license_id', 'specialty', 'verified_at', 
            'is_online', 'is_staff', 'is_active', 'ghost_profile'
        ]
        read_only_fields = ['id', 'role', 'verified_at', 'is_online', 'is_staff', 'is_active', 'ghost_profile']

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

    first_name = serializers.CharField(required=False)
    last_name = serializers.CharField(required=False)
    email = serializers.EmailField(required=True)

    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'phone_number', 'role', 'first_name', 'last_name', 'license_id', 'specialty']

    def validate_email(self, value):
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value

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

class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ['id', 'user', 'token', 'device_type', 'created_at', 'last_used']
        read_only_fields = ['id', 'user', 'created_at', 'last_used']
