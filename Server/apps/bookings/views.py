from rest_framework import viewsets, permissions, status, decorators
from rest_framework.response import Response
from django.utils import timezone
from django.db import transaction
from django.shortcuts import get_object_or_404
from .models import AppointmentSlot, BookingTransaction
from .serializers import AppointmentSlotSerializer, CreateSlotSerializer

class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = AppointmentSlot.objects.all()
    serializer_class = AppointmentSlotSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs = AppointmentSlot.objects.all()
        
        # Patients see only their booked slots OR available slots
        if user.role == 'patient':
            # View own appointments OR view all available slots for booking
            if self.action == 'list':
                # By default list available slots. 
                # Use query params ?mode=mine to see own history
                mode = self.request.query_params.get('mode')
                if mode == 'mine':
                    return qs.filter(patient=user)
                return qs.filter(status=AppointmentSlot.Status.AVAILABLE, start_time__gte=timezone.now())
        
        # Doctors see their own slots
        if user.role == 'doctor':
            return qs.filter(doctor=user)
            
        return qs

    def perform_create(self, serializer):
        # Only doctors can create slots
        if self.request.user.role != 'doctor':
            raise permissions.PermissionDenied("Only doctors can create appointment slots.")
        serializer.save(doctor=self.request.user)

    def get_serializer_class(self):
        if self.action == 'create':
            return CreateSlotSerializer
        return AppointmentSlotSerializer

    @decorators.action(detail=True, methods=['post'], url_path='reserve')
    def reserve(self, request, pk=None):
        """
        Patient reserves a slot.
        Logic: Check if available -> Set status to RESERVED -> Create pending Transaction.
        """
        slot = self.get_object()
        user = request.user
        
        if user.role != 'patient':
            return Response({"error": "Only patients can book."}, status=403)

        if slot.status != AppointmentSlot.Status.AVAILABLE:
            return Response({"error": "Slot is not available."}, status=400)

        # Atomic reservation
        with transaction.atomic():
            slot.status = AppointmentSlot.Status.RESERVED
            slot.patient = user
            slot.reserved_at = timezone.now()
            slot.save()
            
            # Create transaction record
            booking_tx = BookingTransaction.objects.create(
                slot=slot,
                patient=user,
                amount=slot.cost,
                payment_status=BookingTransaction.Status.PENDING
            )
            
        return Response({
            "message": "Slot reserved. Please confirm payment within 5 minutes.",
            "transaction_id": booking_tx.id,
            "slot": AppointmentSlotSerializer(slot).data
        })

    @decorators.action(detail=True, methods=['post'], url_path='confirm')
    def confirm(self, request, pk=None):
        """
        Confirm booking (Simulate Payment Success)
        """
        slot = self.get_object()
        user = request.user
        
        # Verify ownership
        if slot.patient != user:
            return Response({"error": "Not your reservation."}, status=403)
            
        if slot.status != AppointmentSlot.Status.RESERVED:
            return Response({"error": "Slot is not in reserved state."}, status=400)

        # Confirm
        with transaction.atomic():
            slot.status = AppointmentSlot.Status.CONFIRMED
            slot.save()
            
            # Update transaction
            tx = BookingTransaction.objects.filter(slot=slot, patient=user).last()
            if tx:
                tx.payment_status = BookingTransaction.Status.COMPLETED
                tx.save()

        return Response({
            "message": "Booking confirmed!",
            "slot": AppointmentSlotSerializer(slot).data
        })
