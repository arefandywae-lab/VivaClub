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
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=255)
    host = models.ForeignKey(GhostProfile, on_delete=models.CASCADE, related_name='hosted_rooms')
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='general')
    
    # We can track participants using LiveKit webhooks, but keeping a count is useful for listing
    listeners_count = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.host.display_name})"
