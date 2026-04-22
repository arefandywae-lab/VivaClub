from rest_framework import viewsets, permissions
from .models import Message
from .serializers import MessageSerializer

class MessageViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        room_id = self.request.query_params.get('room_id')
        if not room_id:
            return Message.objects.none()
        
        # Security: Ensure user is part of the room
        # For 1-on-1: room_id contains the user_id
        # For Clubhouse: Check Room membership (if we had a membership model)
        # For now, simple check: if "dm_" then must contain user.id
        if room_id.startswith('dm_'):
            if str(self.request.user.id) not in room_id:
                 return Message.objects.none()
                 
        return Message.objects.filter(room_id=room_id).order_by('created_at')
