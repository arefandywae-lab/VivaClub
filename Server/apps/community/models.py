import uuid
from django.db import models
from django.conf import settings

class GhostProfile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ghost_profile')
    display_name = models.CharField(max_length=255)
    avatar_url = models.URLField(max_length=500, blank=True, null=True)
    followers_count = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return self.display_name

class GhostSubscription(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    follower = models.ForeignKey(GhostProfile, on_delete=models.CASCADE, related_name='following')
    target = models.ForeignKey(GhostProfile, on_delete=models.CASCADE, related_name='followers')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['follower', 'target'], name='unique_ghost_follow')
        ]
class Room(models.Model):
    CATEGORY_CHOICES = [
        ('general', 'General'),
        ('depression', 'Depression Support'),
        ('anxiety', 'Anxiety Support'),
        ('relationships', 'Relationships'),
        ('burnout', 'Burnout'),
        ('sleep', 'Sleep'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=255)
    host = models.ForeignKey(GhostProfile, on_delete=models.CASCADE, related_name='hosted_rooms')
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='general')
    
    # Enhanced Discovery Fields
    description = models.TextField(blank=True, default='')  # Room description
    tags = models.JSONField(default=list)  # List of tags ['anxiety', 'support', 'safe-space']
    scheduled_at = models.DateTimeField(null=True, blank=True)  # For scheduled rooms
    is_scheduled = models.BooleanField(default=False)  # Is this a scheduled room?
    trending_score = models.FloatField(default=0.0)  # Calculated trending score
    peak_listeners = models.IntegerField(default=0)  # Max listeners ever in this room
    
    # We can track participants using LiveKit webhooks, but keeping a count is useful for listing
    listeners_count = models.IntegerField(default=0)
    last_active_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.host.display_name})"

class Notification(models.Model):
    """Notifications for users (ghost room opened, hand raise accepted, etc.)"""
    TYPE_CHOICES = [
        ('ghost_room_opened', 'Followed Ghost Opened Room'),
        ('hand_raise_accepted', 'Hand Raise Accepted'),
        ('room_invite', 'Room Invite'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=50, choices=TYPE_CHOICES)
    title = models.CharField(max_length=255)
    body = models.TextField()
    data = models.JSONField(default=dict)  # Extra data (room_id, ghost_id, etc.)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.username} - {self.type}"

class FCMToken(models.Model):
    """Firebase Cloud Messaging tokens for push notifications"""
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='fcm_token')
    token = models.CharField(max_length=255)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.username}'s FCM Token"
