from rest_framework import serializers
from .models import Message, ReadReceipt
from django.contrib.auth import get_user_model

User = get_user_model()

class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source='sender.display_name', read_only=True)
    
    class Meta:
        model = Message
        fields = ['id', 'sender', 'sender_name', 'room_id', 'content', 'created_at', 'is_redacted']
        read_only_fields = ['id', 'sender', 'created_at']

class ReadReceiptSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReadReceipt
        fields = '__all__'
