import uuid
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings

class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    class Role(models.TextChoices):
        PATIENT = 'patient', 'Patient'
        DOCTOR = 'doctor', 'Doctor'
        ADMIN = 'admin', 'Admin'

    role = models.CharField(max_length=10, choices=Role.choices, default=Role.PATIENT)
    display_name = models.CharField(max_length=255, blank=True, null=True)
    phone_number = models.CharField(max_length=15, unique=True, blank=True, null=True)
    
    # Doctor Specifics
    license_id = models.CharField(max_length=50, blank=True, null=True)
    specialty = models.CharField(max_length=100, blank=True, null=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    is_online = models.BooleanField(default=False)
    
    def __str__(self):
        return self.username

class DeviceToken(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='device_tokens')
    token = models.TextField(unique=True)
    device_type = models.CharField(max_length=20, choices=[('ios', 'iOS'), ('android', 'Android'), ('web', 'Web')])
    created_at = models.DateTimeField(auto_now_add=True)
    last_used = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user} - {self.device_type}"
