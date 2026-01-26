import uuid
from django.db import models
from django.conf import settings

class Assessment(models.Model):
    class RiskLevel(models.TextChoices):
        LOW = 'LOW', 'Low'
        MODERATE = 'MODERATE', 'Moderate'
        SEVERE = 'SEVERE', 'Severe'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='assessments')
    total_score = models.IntegerField()
    answers = models.JSONField(default=dict) # Stores question:score map
    risk_level = models.CharField(max_length=20, choices=RiskLevel.choices)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.patient} - {self.risk_level} ({self.total_score})"

class OpdNote(models.Model):
    """Doctor notes, E2EE encrypted content"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    appointment_id = models.UUIDField(null=True, blank=True) # Soft link to appointment
    doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='authored_opd_notes')
    patient_id = models.UUIDField() # ID of patient, can be a ForeignKey if we strictly link, but keeping flexible
    encrypted_content = models.TextField()
    iv = models.CharField(max_length=255) # Initialization Vector
    created_at = models.DateTimeField(auto_now_add=True)
    
class PersonalNote(models.Model):
    """Patient personal notes"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='personal_notes')
    encrypted_content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
