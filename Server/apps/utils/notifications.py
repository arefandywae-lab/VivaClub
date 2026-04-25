import firebase_admin
from firebase_admin import messaging
from apps.users.models import DeviceToken
import logging

logger = logging.getLogger(__name__)

def send_push_notification(user, title, body, data=None):
    """
    Sends a push notification to all devices registered for a user.
    """
    tokens = DeviceToken.objects.filter(user=user).values_list('token', flat=True)
    
    if not tokens:
        logger.info(f"No device tokens found for user {user.username}")
        return

    # Create message
    messages = [
        messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=token,
        ) for token in tokens
    ]

    try:
        # Send all messages
        response = messaging.send_each(messages)
        logger.info(f"Successfully sent {response.success_count} notifications to user {user.username}")
        return response
    except Exception as e:
        logger.error(f"Error sending push notification: {e}")
        return None

def notify_sos_to_doctors(sos_call):
    """
    Broadcasts SOS notification to all online doctors.
    """
    from apps.users.models import User
    online_doctors = User.objects.filter(role=User.Role.DOCTOR, is_online=True)
    
    for doctor in online_doctors:
        send_push_notification(
            user=doctor,
            title="🚨 EMERGENCY SOS",
            body=f"Patient {sos_call.patient.display_name} needs urgent help! PHQ-9 Score: {sos_call.priority_score}",
            data={
                "type": "SOS",
                "sos_id": str(sos_call.id),
                "patient_name": sos_call.patient.display_name
            }
        )

def broadcast_test_push():
    """
    Broadcasts a test notification to ALL registered device tokens in the system.
    """
    tokens = DeviceToken.objects.all().values_list('token', flat=True)
    if not tokens:
        return 0
    
    messages = [
        messaging.Message(
            notification=messaging.Notification(
                title="🔔 VivaClub System Test",
                body="This is a test push notification from the admin dashboard. Everything is working!",
            ),
            data={"type": "TEST"},
            token=token,
        ) for token in tokens
    ]
    
    try:
        response = messaging.send_each(messages)
        return response.success_count
    except Exception as e:
        logger.error(f"Broadcast test failed: {e}")
        return 0
