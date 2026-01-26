from rest_framework import serializers
from .models import AppointmentSlot, BookingTransaction
from apps.users.serializers import UserSerializer

class AppointmentSlotSerializer(serializers.ModelSerializer):
    doctor_details = UserSerializer(source='doctor', read_only=True)
    
    class Meta:
        model = AppointmentSlot
        fields = ['id', 'doctor', 'doctor_details', 'start_time', 'end_time', 'status', 'cost', 'patient']
        read_only_fields = ['id', 'status', 'patient', 'doctor']

class CreateSlotSerializer(serializers.ModelSerializer):
    """Serializer for Doctors to create slots"""
    class Meta:
        model = AppointmentSlot
        fields = ['start_time', 'end_time', 'cost']

    def validate(self, data):
        if data['start_time'] >= data['end_time']:
            raise serializers.ValidationError("End time must be after start time.")
        return data

class ReserveSlotSerializer(serializers.Serializer):
    """Action serializer for reserving a slot"""
    slot_id = serializers.UUIDField()

class ConfirmBookingSerializer(serializers.Serializer):
    """Action serializer for confirming (mock payment)"""
    transaction_id = serializers.UUIDField()
