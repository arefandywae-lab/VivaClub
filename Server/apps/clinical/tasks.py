from django.utils import timezone
from datetime import timedelta
from .models import Appointment
from apps.utils.notifications import send_push_notification
import logging

logger = logging.getLogger(__name__)

def send_appointment_reminders():
    """
    Task to send reminders 15 minutes before an appointment starts.
    Runs every minute.
    """
    now = timezone.now()
    target_time = now + timedelta(minutes=15)
    
    # Use a small window to avoid missing appointments due to timing
    start_window = target_time.replace(second=0, microsecond=0)
    end_window = start_window + timedelta(seconds=59)
    
    appointments = Appointment.objects.filter(
        slot__start_time__range=(start_window, end_window),
        status=Appointment.Status.CONFIRMED
    )
    
    for appt in appointments:
        # Notify Patient
        send_push_notification(
            user=appt.patient,
            title="Appointment Reminder",
            body=f"Your appointment with {appt.doctor.display_name} starts in 15 minutes."
        )
        
        # Notify Doctor
        send_push_notification(
            user=appt.doctor,
            title="Appointment Reminder",
            body=f"Your appointment with {appt.patient.display_name} starts in 15 minutes."
        )
        
    if appointments.count() > 0:
        logger.info(f"Sent reminders for {appointments.count()} appointments.")

def update_doctor_stats(doctor_id):
    """
    Task to aggregate ratings and reviews for a doctor.
    Can be called manually or scheduled.
    """
    from django.db.models import Avg, Count
    from .models import DoctorReview
    from apps.users.models import User
    
    stats = DoctorReview.objects.filter(doctor_id=doctor_id).aggregate(
        avg_rating=Avg('rating'),
        review_count=Count('id')
    )
    
    # We could store these in a dedicated DoctorProfile model or cache
    # For now, let's just log it or we could add fields to User model if needed
    logger.info(f"Stats for Doctor {doctor_id}: {stats}")
    return stats
