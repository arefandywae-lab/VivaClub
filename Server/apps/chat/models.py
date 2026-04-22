import uuid
from django.db import models
from django.conf import settings

class Message(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sent_messages')
    
    # Generic flexibility: Can be 1-on-1 (user_id pairing) or Room-based
    # For now, let's allow a flexible room_id string. 
    # For 1-on-1: "dm_userA_userB" (sorted)
    # For Clubhouse: "room_UUID"
    room_id = models.CharField(max_length=255, db_index=True)
    
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    # Optional: Parsing for DLP (Data Loss Prevention) flags
    is_redacted = models.BooleanField(default=False)
    
    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"{self.sender} -> {self.room_id}: {self.content[:20]}"

class ReadReceipt(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='read_receipts')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    read_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('message', 'user')
