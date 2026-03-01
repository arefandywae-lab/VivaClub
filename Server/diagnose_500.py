import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

print("Testing Room Close Action Logic...")

from apps.community.models import Room
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

room = Room.objects.filter(is_active=True).first()
if room:
    print(f"Found active room: {room.id}")
    try:
        # Simulate the close action
        room.is_active = False
        room.save()
        print("Room saved as inactive.")
        
        # Simulate websocket broadcast
        print("Attempting WebSocket Broadcast...")
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            "admin_updates",
            {
                "type": "admin_update",
                "payload": {
                    "event": "room_closed",
                    "room_id": str(room.id)
                }
            }
        )
        print("Broadcast successful!")
        
    except Exception as e:
        import traceback
        print("ERROR CAUGHT DURING CLOSE SIMULATION:")
        traceback.print_exc()
else:
    print("No active rooms found to simulate close.")
    
    print("Testing Redis Connection directly just in case...")
    try:
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            "admin_updates",
            {"type": "admin_update", "payload": {"event": "ping"}}
        )
        print("Redis Channel Layer Ping Successful.")
    except Exception as e:
        import traceback
        print("ERROR CAUGHT DURING REDIS PING:")
        traceback.print_exc()
