import json
from channels.generic.websocket import AsyncWebsocketConsumer

class AdminDashboardConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get("user")
        
        # Verify if user is admin
        # In a real setup, we might need a more robust check or an auth token middleware
        if self.user and self.user.is_authenticated and self.user.is_staff:
            await self.channel_layer.group_add(
                "admin_updates",
                self.channel_name
            )
            await self.accept()
        else:
            # Reject connection if not admin
            await self.close()

    async def disconnect(self, close_code):
        if self.user and self.user.is_authenticated and self.user.is_staff:
            await self.channel_layer.group_discard(
                "admin_updates",
                self.channel_name
            )

    # Receive message from room group (Broadcasted by webhooks)
    async def admin_update(self, event):
        payload = event['payload']

        # Send message to WebSocket
        await self.send(text_data=json.dumps(payload))
