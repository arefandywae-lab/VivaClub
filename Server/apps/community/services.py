"""
Notification service for sending push notifications to users
"""
import logging
from django.conf import settings
from .models import Notification, FCMToken, GhostSubscription, GhostProfile

logger = logging.getLogger(__name__)

# Check if Firebase is available
try:
    import firebase_admin
    from firebase_admin import messaging
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    logger.warning("Firebase Admin SDK not available. Push notifications will be disabled.")


class NotificationService:
    """Service for creating and sending notifications"""
    
    @staticmethod
    def send_ghost_room_notification(ghost_id, room_id, room_title):
        """
        Send notification to all followers when a ghost opens a room
        
        Args:
            ghost_id: UUID of the ghost who opened the room
            room_id: UUID of the room
            room_title: Title of the room
        """
        try:
            ghost = GhostProfile.objects.get(id=ghost_id)
        except GhostProfile.DoesNotExist:
            logger.error(f"Ghost {ghost_id} not found")
            return
        
        # Get all followers
        subscriptions = GhostSubscription.objects.filter(
            target_id=ghost_id
        ).select_related('follower__user')
        
        notification_count = 0
        fcm_sent = 0
        
        for subscription in subscriptions:
            user = subscription.follower.user
            
            # Create notification record
            notification = Notification.objects.create(
                user=user,
                type='ghost_room_opened',
                title=f'{ghost.display_name} opened a room',
                body=f'Join "{room_title}" now!',
                data={
                    'room_id': str(room_id),
                    'ghost_id': str(ghost_id),
                    'room_title': room_title
                }
            )
            notification_count += 1
            
            # Send FCM push notification if available
            if FIREBASE_AVAILABLE and hasattr(user, 'fcm_token'):
                try:
                    message = messaging.Message(
                        notification=messaging.Notification(
                            title=f'{ghost.display_name} opened a room',
                            body=f'Join "{room_title}" now!'
                        ),
                        data={
                            'type': 'ghost_room_opened',
                            'room_id': str(room_id),
                            'ghost_id': str(ghost_id),
                            'room_title': room_title
                        },
                        token=user.fcm_token.token
                    )
                    messaging.send(message)
                    fcm_sent += 1
                except Exception as e:
                    logger.error(f'Failed to send FCM to user {user.id}: {e}')
        
        logger.info(f'Sent {notification_count} notifications ({fcm_sent} FCM) for room {room_id}')
        return notification_count
    
    @staticmethod
    def send_hand_raise_accepted_notification(user_id, room_id, room_title):
        """
        Send notification when user's hand raise is accepted
        
        Args:
            user_id: ID of the user whose hand was raised
            room_id: UUID of the room
            room_title: Title of the room
        """
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            logger.error(f"User {user_id} not found")
            return
        
        # Create notification
        notification = Notification.objects.create(
            user=user,
            type='hand_raise_accepted',
            title='You can now speak!',
            body=f'Your hand raise was accepted in "{room_title}"',
            data={
                'room_id': str(room_id),
                'room_title': room_title
            }
        )
        
        # Send FCM if available
        if FIREBASE_AVAILABLE and hasattr(user, 'fcm_token'):
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title='You can now speak!',
                        body=f'Your hand raise was accepted in "{room_title}"'
                    ),
                    data={
                        'type': 'hand_raise_accepted',
                        'room_id': str(room_id),
                        'room_title': room_title
                    },
                    token=user.fcm_token.token
                )
                messaging.send(message)
                logger.info(f'Sent hand raise notification to user {user_id}')
            except Exception as e:
                logger.error(f'Failed to send FCM to user {user_id}: {e}')
