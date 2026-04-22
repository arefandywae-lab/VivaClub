from django.db import transaction
from rest_framework import viewsets, permissions, status, filters
from rest_framework.response import Response
from rest_framework.decorators import action
from django.utils import timezone
from .models import Assessment, OpdNote, PersonalNote, TimeSlot, Appointment, SOSCall, DoctorReview
from .serializers import (
    AssessmentSerializer, OpdNoteSerializer, PersonalNoteSerializer,
    TimeSlotSerializer, AppointmentSerializer, SOSCallSerializer, 
    DoctorReviewSerializer, UserMinimalSerializer
)
from django.contrib.auth import get_user_model

User = get_user_model()

class AssessmentViewSet(viewsets.ModelViewSet):
    serializer_class = AssessmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == User.Role.DOCTOR:
             return Assessment.objects.all()
        return Assessment.objects.filter(patient=user)

    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)

class DoctorViewSet(viewsets.ReadOnlyModelViewSet):
    """Viewset for patients to browse and filter doctors"""
    queryset = User.objects.filter(role=User.Role.DOCTOR, verified_at__isnull=False)
    serializer_class = UserMinimalSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['display_name', 'specialty']

    def get_queryset(self):
        queryset = super().get_queryset()
        specialty = self.request.query_params.get('specialty')
        is_online = self.request.query_params.get('is_online')
        
        if specialty:
            queryset = queryset.filter(specialty__icontains=specialty)
        if is_online is not None:
            queryset = queryset.filter(is_online=is_online.lower() == 'true')
            
        return queryset

class TimeSlotViewSet(viewsets.ModelViewSet):
    serializer_class = TimeSlotSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        doctor_id = self.request.query_params.get('doctor_id')
        if doctor_id:
            return TimeSlot.objects.filter(doctor_id=doctor_id, start_time__gte=timezone.now(), is_reserved=False)
        
        user = self.request.user
        if user.role == User.Role.DOCTOR:
            return TimeSlot.objects.filter(doctor=user)
        return TimeSlot.objects.none()

    def perform_create(self, serializer):
        if self.request.user.role != User.Role.DOCTOR:
            raise permissions.PermissionDenied("Only doctors can create time slots.")
        serializer.save(doctor=self.request.user)

class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class = AppointmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == User.Role.DOCTOR:
            return Appointment.objects.filter(doctor=user)
        return Appointment.objects.filter(patient=user)

    @transaction.atomic
    def perform_create(self, serializer):
        slot_id = self.request.data.get('slot')
        # Lock the slot row for update to prevent race conditions
        slot = TimeSlot.objects.select_for_update().get(id=slot_id)
        
        if slot.is_reserved:
            raise serializers.ValidationError("This slot is already reserved.")
        
        # Mark slot as reserved atomically
        slot.is_reserved = True
        slot.save()
        
        serializer.save(patient=self.request.user, doctor=slot.doctor)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        appointment = self.get_object()
        # 24h cancellation policy
        if appointment.slot.start_time - timezone.now() < timezone.timedelta(hours=24):
             return Response({"error": "Cannot cancel within 24 hours of appointment."}, status=status.HTTP_400_BAD_REQUEST)
        
        appointment.status = Appointment.Status.CANCELLED
        appointment.slot.is_reserved = False
        appointment.slot.save()
        appointment.save()
        return Response({"status": "Appointment cancelled"})

class SOSCallViewSet(viewsets.ModelViewSet):
    serializer_class = SOSCallSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == User.Role.DOCTOR:
            return SOSCall.objects.filter(status=SOSCall.Status.WAITING)
        return SOSCall.objects.filter(patient=user)

    def create(self, request, *args, **kwargs):
        # Logic to unlock SOS based on PHQ-9 score
        latest_assessment = Assessment.objects.filter(patient=request.user).order_by('-created_at').first()
        if not latest_assessment or latest_assessment.total_score < 19:
             return Response({"error": "SOS button is only available for high-risk assessments (Score >= 19)."}, status=status.HTTP_403_FORBIDDEN)
        
        # Priority score = PHQ-9 total score
        priority_score = latest_assessment.total_score
        
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(patient=request.user, priority_score=priority_score)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class DoctorReviewViewSet(viewsets.ModelViewSet):
    serializer_class = DoctorReviewSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DoctorReview.objects.all()

    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)

class OpdNoteViewSet(viewsets.ModelViewSet):
    serializer_class = OpdNoteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == User.Role.DOCTOR:
            return OpdNote.objects.filter(doctor=user)
        return OpdNote.objects.filter(patient=user)

    def perform_create(self, serializer):
        if self.request.user.role != User.Role.DOCTOR:
             raise permissions.PermissionDenied("Only doctors can write OPD notes.")
        serializer.save(doctor=self.request.user)

class PersonalNoteViewSet(viewsets.ModelViewSet):
    serializer_class = PersonalNoteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return PersonalNote.objects.filter(patient=self.request.user)

    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)
