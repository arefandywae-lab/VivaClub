import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone

class AppointmentSlot(models.Model):
    class Status(models.TextChoices):
        AVAILABLE = 'AVAILABLE', 'Available'
        RESERVED = 'RESERVED', 'Reserved'
        CONFIRMED = 'CONFIRMED', 'Confirmed'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='doctor_slots')
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.AVAILABLE)
    reserved_at = models.DateTimeField(null=True, blank=True)
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='patient_appointments')
    cost = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    class Meta:
        constraints = [
            models.CheckConstraint(check=models.Q(start_time__lt=models.F('end_time')), name='check_start_before_end'),
            # Postgres Exclusion constraint requires django.contrib.postgres or manual SQL. 
            # Ideally we use logic or specific constraint, but simplest is UniqueTogether if slots are strictly grid based.
            # For now, unique doctor + start_time is a good basic guard.
            models.UniqueConstraint(fields=['doctor', 'start_time'], name='unique_doctor_slot')
        ]
    
    def __str__(self):
        return f"{self.doctor} - {self.start_time}"

class BookingTransaction(models.Model):
    class Status(models.TextChoices):
        PENDING = 'PENDING', 'Pending'
        COMPLETED = 'COMPLETED', 'Completed'
        FAILED = 'FAILED', 'Failed'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    slot = models.ForeignKey(AppointmentSlot, on_delete=models.CASCADE, related_name='transactions')
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='transactions')
    payment_status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Tx {self.id} - {self.payment_status}"
