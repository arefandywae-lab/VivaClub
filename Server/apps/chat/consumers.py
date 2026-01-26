import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.utils import timezone
from .models import Message

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Room name from URL
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'
        self.user = self.scope["user"]

        if self.user.is_authenticated:
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

    # ... receive and chat_message methods remain same ...

    @database_sync_to_async
    def update_user_status(self, is_online):
        from django.contrib.auth import get_user_model
        User = get_user_model()
        User.objects.filter(id=self.user.id).update(is_online=is_online)


    # Receive message from WebSocket
    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data.get('message')
        # In a real app, you'd want to validate inputs and maybe use serializers
        
        user_id = self.scope["user"].id if self.scope["user"].is_authenticated else None
        username = self.scope["user"].username if self.scope["user"].is_authenticated else "Anonymous"

        if not message:
            return

        # Save message to DB
        if user_id:
            await self.save_message(user_id, self.room_id, message)

        # Send message to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message,
                'sender': username,
                'timestamp': str(timezone.now())
            }
        )

    # Receive message from room group
    async def chat_message(self, event):
        message = event['message']
        sender = event['sender']
        timestamp = event['timestamp']

        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'message': message,
            'sender': sender,
            'timestamp': timestamp
        }))

    @database_sync_to_async
    def save_message(self, user_id, room_id, content):
        Message.objects.create(sender_id=user_id, room_id=room_id, content=content)
