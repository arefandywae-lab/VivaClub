from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import Message, ReadReceipt
from .serializers import MessageSerializer

class MessageViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        room_id = self.request.query_params.get('room_id')
        if not room_id:
            return Message.objects.none()
        
        if room_id.startswith('dm_'):
            if str(self.request.user.id) not in room_id:
                 return Message.objects.none()
                 
        return Message.objects.filter(room_id=room_id).order_by('created_at')

    @action(detail=False, methods=['post'])
    def mark_read(self, request):
        room_id = request.data.get('room_id')
        if not room_id:
            return Response({"error": "room_id is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Get all unread messages in this room not sent by the current user
        messages = Message.objects.filter(room_id=room_id).exclude(sender=request.user)
        
        for msg in messages:
            ReadReceipt.objects.get_or_create(
                message=msg,
                user=request.user,
                defaults={'read_at': timezone.now()}
            )
            
        return Response({"status": "Messages marked as read"})
