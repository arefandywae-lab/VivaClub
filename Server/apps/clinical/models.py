import uuid
from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator

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

class TimeSlot(models.Model):
    """Doctor availability slots"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='availability_slots')
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    is_reserved = models.BooleanField(default=False)
    is_confirmed = models.BooleanField(default=False)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)

    class Meta:
        ordering = ['start_time']

    def __str__(self):
        return f"Slot: {self.doctor.display_name} @ {self.start_time}"

class Appointment(models.Model):
    class Status(models.TextChoices):
        PENDING = 'PENDING', 'Pending'
        CONFIRMED = 'CONFIRMED', 'Confirmed'
        COMPLETED = 'COMPLETED', 'Completed'
        CANCELLED = 'CANCELLED', 'Cancelled'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='appointments')
    doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='doctor_appointments')
    slot = models.OneToOneField(TimeSlot, on_delete=models.PROTECT, related_name='appointment')
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Appt: {self.patient} -> {self.doctor} ({self.status})"

class SOSCall(models.Model):
    class Status(models.TextChoices):
        WAITING = 'WAITING', 'Waiting'
        ONGOING = 'ONGOING', 'Ongoing'
        RESOLVED = 'RESOLVED', 'Resolved'
        CANCELLED = 'CANCELLED', 'Cancelled'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sos_calls')
    assigned_doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_sos_calls')
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.WAITING)
    priority_score = models.IntegerField(default=0) # Higher score = Higher risk from PHQ-9
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-priority_score', 'created_at']

class DoctorReview(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    appointment = models.OneToOneField(Appointment, on_delete=models.CASCADE, related_name='review')
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='reviews')
    rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

class OpdNote(models.Model):
    """Doctor notes, E2EE encrypted content"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    appointment = models.OneToOneField(Appointment, on_delete=models.SET_NULL, null=True, blank=True, related_name='opd_note')
    doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='authored_opd_notes')
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, null=True, blank=True, related_name='received_opd_notes')
    encrypted_content = models.TextField()
    iv = models.CharField(max_length=255) # Initialization Vector
    created_at = models.DateTimeField(auto_now_add=True)
    
class PersonalNote(models.Model):
    """Patient personal notes"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='personal_notes')
    encrypted_content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
