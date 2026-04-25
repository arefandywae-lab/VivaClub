import uuid
from django.db import models
from django.conf import settings

class GhostProfile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ghost_profile')
    display_name = models.CharField(max_length=255)
    avatar_url = models.URLField(max_length=500, blank=True, null=True)
    bio = models.TextField(blank=True, default='')  # About me / bio
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
    last_active_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    # New fields for permissions and moderation
    banned_users = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='banned_from_rooms', blank=True)
    moderators = models.ManyToManyField(GhostProfile, related_name='moderated_rooms', blank=True)

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

class UserTrustScore(models.Model):
    """Tracks a user's trust level in the community to prevent abuse"""
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='trust_score')
    score = models.IntegerField(default=100) # 0-200. Drops on valid reports, rises on approved reports.
    total_reports_received = models.IntegerField(default=0)
    valid_reports_received = models.IntegerField(default=0)
    total_reports_made = models.IntegerField(default=0)
    last_updated = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.username} - Score: {self.score}"

class RoomReport(models.Model):
    """Reports made against users in a room"""
    REASON_CHOICES = [
        ('harassment', 'Harassment or Bullying'),
        ('spam', 'Spam or Promotional'),
        ('inappropriate', 'Inappropriate Content'),
        ('self_harm', 'Self-Harm Threats'),
        ('other', 'Other')
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('valid', 'Valid Report'),
        ('invalid', 'Invalid/False Report')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    reporter = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='reports_made')
    reported_user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='reports_received')
    room = models.ForeignKey('Room', on_delete=models.SET_NULL, null=True, related_name='reports')
    reason = models.CharField(max_length=50, choices=REASON_CHOICES)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    resolved_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='reports_resolved')
    
    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Report against {self.reported_user.username} by {self.reporter.username}"

class BlockedUser(models.Model):
    """Allows a ghost profile to block another ghost profile"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    blocker = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='blocks_made')
    blocked = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='blocked_by')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['blocker', 'blocked'], name='unique_block')
        ]
    
    def __str__(self):
        return f"{self.blocker.username} blocked {self.blocked.username}"
