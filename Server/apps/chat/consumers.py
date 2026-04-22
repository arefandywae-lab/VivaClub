import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.utils import timezone
from .models import Message
from apps.utils.notifications import send_push_notification

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'
        self.user = self.scope["user"]

        if not self.user.is_authenticated:
            await self.close()
            return

        # Validate room access (Simple 1-on-1 logic: room_id contains user_id)
        if self.room_id.startswith('dm_'):
            if str(self.user.id) not in self.room_id:
                await self.close()
                return

        await self.update_user_status(True)

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        if self.user.is_authenticated:
            await self.update_user_status(False)

        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message_content = data.get('message')
        
        if not message_content:
            return

        # Save to DB
        new_msg = await self.save_message(self.user.id, self.room_id, message_content)

        # Send message to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message_content,
                'sender_id': str(self.user.id),
                'sender_name': self.user.display_name or self.user.username,
                'timestamp': str(timezone.now())
            }
        )
        
        # Logic to notify the other party if they are not "online" in this room
        # For simplicity, we can trigger a notification helper
        await self.trigger_push_notification(message_content)

    async def chat_message(self, event):
        # Don't send back to the sender (optional, but UI usually handles it)
        # if event['sender_id'] == str(self.user.id): return

        await self.send(text_data=json.dumps(event))

    @database_sync_to_async
    def update_user_status(self, is_online):
        from apps.users.models import User
        User.objects.filter(id=self.user.id).update(is_online=is_online)

    @database_sync_to_async
    def save_message(self, user_id, room_id, content):
        return Message.objects.create(sender_id=user_id, room_id=room_id, content=content)

    @database_sync_to_async
    def trigger_push_notification(self, content):
        """
        Identify the recipient and send a push if they're not in the websocket group.
        (Advanced logic would check group membership, but here we just try to send)
        """
        from apps.users.models import User
        # Logic to find the OTHER user in the dm_ room
        ids = self.room_id.replace('dm_', '').split('_')
        other_id = next((uid for uid in ids if uid != str(self.user.id)), None)
        
        if other_id:
            try:
                recipient = User.objects.get(id=other_id)
                send_push_notification(
                    user=recipient,
                    title=f"New message from {self.user.display_name or self.user.username}",
                    body=content[:100],
                    data={"type": "CHAT", "room_id": self.room_id}
                )
            except User.DoesNotExist:
                pass
