from django.db import transaction, models
from rest_framework import viewsets, permissions, status, filters, serializers
from rest_framework.views import APIView
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

    @transaction.atomic
    def perform_create(self, serializer):
        user = self.request.user
        now = timezone.now()
        
        # 1. Check if already done within 24 hours
        if user.last_assessment_date and now - user.last_assessment_date < timezone.timedelta(hours=24):
            raise serializers.ValidationError("You can only take the assessment once every 24 hours.")

        # 2. Save assessment
        assessment = serializer.save(patient=user)
        
        # 3. Update Mood
        user.current_mood = assessment.risk_level
        
        # 4. Handle Streak
        if user.last_assessment_date:
            # If done between 24 and 48 hours ago, increment streak
            if now - user.last_assessment_date < timezone.timedelta(hours=48):
                user.streak_count += 1
            else:
                # Reset streak if missed more than 48 hours
                user.streak_count = 1
        else:
            # First time assessment
            user.streak_count = 1
            
        user.last_assessment_date = now
        user.save()

class DoctorViewSet(viewsets.ReadOnlyModelViewSet):
    """Viewset for patients to browse and filter doctors"""
    queryset = User.objects.filter(role=User.Role.DOCTOR, verified_at__isnull=False)
    serializer_class = UserMinimalSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['display_name', 'specialty']

    def get_queryset(self):
        queryset = super().get_queryset().annotate(
            avg_rating=models.Avg('reviews__rating'),
            review_count=models.Count('reviews', distinct=True)
        )
        specialty = self.request.query_params.get('specialty')
        is_online = self.request.query_params.get('is_online')
        
        if specialty:
            queryset = queryset.filter(specialty__icontains=specialty)
        if is_online is not None:
            queryset = queryset.filter(is_online=is_online.lower() == 'true')
        return queryset

    @action(detail=False, methods=['get'])
    def dashboard(self, request):
        if request.user.role != User.Role.DOCTOR:
             return Response({"error": "Only doctors can access the dashboard."}, status=status.HTTP_403_FORBIDDEN)
        
        today = timezone.now().date()
        today_appointments = Appointment.objects.filter(
            doctor=request.user,
            slot__start_time__date=today
        ).count()
        
        waiting_sos = SOSCall.objects.filter(status=SOSCall.Status.WAITING).count()
        
        # Get doctor's own stats
        stats = User.objects.filter(id=request.user.id).annotate(
            avg_rating=models.Avg('reviews__rating'),
            review_count=models.Count('reviews', distinct=True)
        ).values('avg_rating', 'review_count').first()

        return Response({
            "today_appointments_count": today_appointments,
            "waiting_sos_count": waiting_sos,
            "my_stats": stats
        })

    @action(detail=False, methods=['post'])
    def toggle_online(self, request):
        if request.user.role != User.Role.DOCTOR:
             return Response({"error": "Only doctors can toggle online status."}, status=status.HTTP_403_FORBIDDEN)
        
        request.user.is_online = not request.user.is_online
        request.user.save()
        
        return Response({
            "is_online": request.user.is_online,
            "status": "Online" if request.user.is_online else "Offline"
        })

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
    @action(detail=False, methods=['GET'], url_path='admin-list', permission_classes=[permissions.IsAdminUser])
    def admin_list(self, request):
        appointments = Appointment.objects.all().order_by('-created_at')
        page = self.paginate_queryset(appointments)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(appointments, many=True)
        return Response(serializer.data)

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
        
        # Notify Doctor about new request
        try:
            from apps.utils.notifications import send_push_notification
            send_push_notification(
                user=slot.doctor,
                title="New Booking Request",
                body=f"{self.request.user.get_full_name() or self.request.user.username} requested an appointment for {slot.start_time.strftime('%Y-%m-%d %H:%M')}."
            )
        except Exception as e:
            print(f"Failed to notify doctor: {e}")

    @action(detail=True, methods=['post'])
    def confirm(self, request, pk=None):
        appointment = self.get_object()
        if request.user != appointment.doctor:
             return Response({"error": "Only the assigned doctor can confirm the appointment."}, status=status.HTTP_403_FORBIDDEN)
        
        if appointment.status != Appointment.Status.PENDING:
             return Response({"error": "This appointment is not in pending status."}, status=status.HTTP_400_BAD_REQUEST)
        
        appointment.status = Appointment.Status.CONFIRMED
        appointment.save()
        
        # Notify Patient
        try:
            from apps.utils.notifications import send_push_notification
            send_push_notification(
                user=appointment.patient,
                title="Appointment Confirmed",
                body=f"Your appointment with {request.user.display_name} has been confirmed for {appointment.slot.start_time.strftime('%Y-%m-%d %H:%M')}."
            )
        except Exception as e:
            print(f"Failed to notify patient: {e}")
        
        return Response({"status": "Appointment confirmed"})

    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        appointment = self.get_object()
        if request.user != appointment.doctor:
             return Response({"error": "Only the assigned doctor can complete the appointment."}, status=status.HTTP_403_FORBIDDEN)
        
        appointment.status = Appointment.Status.COMPLETED
        appointment.save()
        return Response({"status": "Appointment completed"})

    @action(detail=False, methods=['GET'], url_path='latest_test_token', permission_classes=[])
    def latest_test_token(self, request):
        from django.core.cache import cache
        token_data = cache.get('latest_doctor_token')
        return Response(token_data or {})

    @action(detail=True, methods=['POST'], url_path='join')
    def join(self, request, pk=None):
        appointment = self.get_object()
        if request.user != appointment.patient and request.user != appointment.doctor:
            return Response({"error": "You are not authorized to join this appointment"}, status=403)
        if appointment.status != Appointment.Status.CONFIRMED:
             return Response({"error": "Appointment is not confirmed yet"}, status=400)
        
        from livekit import api
        import os as py_os
        token = api.AccessToken(
            py_os.getenv('LIVEKIT_API_KEY'),
            py_os.getenv('LIVEKIT_API_SECRET'),
        ).with_identity(request.user.username).with_name(request.user.display_name or request.user.username).with_grants(api.VideoGrants(
            room_join=True,
            room=f"appointment_{appointment.id}",
        ))

        # Save for easy web testing using Redis cache
        from livekit import api as lk_api
        doc_token = lk_api.AccessToken(
            py_os.getenv('LIVEKIT_API_KEY'),
            py_os.getenv('LIVEKIT_API_SECRET'),
        ).with_identity('doctor_test_web').with_name('Dr. Test Web').with_grants(lk_api.VideoGrants(
            room_join=True,
            room=f"appointment_{appointment.id}",
        ))
        
        token_data = {
            'token': doc_token.to_jwt(),
            'url': py_os.getenv('LIVEKIT_API_URL'),
            'room_name': f"appointment_{appointment.id}"
        }
        from django.core.cache import cache
        cache.set('latest_doctor_token', token_data, timeout=3600)
        
        return Response({
            "token": token.to_jwt(),
            "url": py_os.getenv('LIVEKIT_API_URL'),
            "room_name": f"appointment_{appointment.id}"
        })

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

class LiveKitWebhookView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        # In a real app, we should verify the signature here
        event = request.data
        event_type = event.get('event')
        
        if event_type == 'room_finished':
            room_name = event.get('room', {}).get('name', '')
            if room_name.startswith('appointment_'):
                appointment_id = room_name.replace('appointment_', '')
                try:
                    appointment = Appointment.objects.get(id=appointment_id)
                    if appointment.status == Appointment.Status.CONFIRMED:
                        appointment.status = Appointment.Status.COMPLETED
                        appointment.save()
                        print(f'✅ Appointment {appointment_id} marked as COMPLETED')
                except Appointment.DoesNotExist:
                    pass
        
        return Response({'status': 'ok'})

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
        
        # Notify Doctors
        try:
            from apps.utils.notifications import notify_sos_to_doctors
            notify_sos_to_doctors(serializer.instance)
        except Exception as e:
            print(f"Failed to send SOS notification: {e}")
            
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'])
    def list_waiting(self, request):
        if request.user.role != User.Role.DOCTOR:
             return Response({"error": "Only doctors can view the SOS waiting list."}, status=status.HTTP_403_FORBIDDEN)
             
        waiting_calls = SOSCall.objects.filter(status=SOSCall.Status.WAITING).order_by('-priority_score', 'created_at')
        serializer = self.get_serializer(waiting_calls, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def accept(self, request, pk=None):
        sos_call = self.get_object()
        if request.user.role != User.Role.DOCTOR:
             return Response({"error": "Only doctors can accept SOS calls."}, status=status.HTTP_403_FORBIDDEN)
        
        if sos_call.status != SOSCall.Status.WAITING:
             return Response({"error": "This SOS call is already being handled."}, status=status.HTTP_400_BAD_REQUEST)
        
        sos_call.status = SOSCall.Status.ONGOING
        sos_call.assigned_doctor = request.user
        sos_call.save()
        
        # Generate LiveKit Token
        from apps.utils.livekit_utils import generate_livekit_token, get_sos_room_name
        room_name = get_sos_room_name(sos_call)
        token = generate_livekit_token(room_name, str(request.user.id), request.user.display_name)
        
        return Response({
            "status": "SOS Accepted",
            "room_name": room_name,
            "livekit_token": token
        })

    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        sos_call = self.get_object()
        if request.user != sos_call.assigned_doctor:
             return Response({"error": "Only the assigned doctor can complete the SOS call."}, status=status.HTTP_403_FORBIDDEN)
        
        sos_call.status = SOSCall.Status.RESOLVED
        sos_call.save()
        
        # Notify Patient
        from apps.utils.notifications import send_push_notification
        send_push_notification(
            user=sos_call.patient,
            title="SOS Resolved",
            body="We hope you are feeling better. Please take care!",
        )
        
        return Response({"status": "SOS call marked as resolved"})

    @action(detail=False, methods=['get'])
    def my_position(self, request):
        user = request.user
        # Check for both WAITING and ONGOING
        active_call = SOSCall.objects.filter(patient=user).filter(
            models.Q(status=SOSCall.Status.WAITING) | models.Q(status=SOSCall.Status.ONGOING)
        ).order_by('-created_at').first()
        
        if not active_call:
            return Response({"position": 0, "status": "none", "message": "No active SOS call."})
        
        if active_call.status == SOSCall.Status.ONGOING:
            from apps.utils.livekit_utils import generate_livekit_token, get_sos_room_name
            room_name = get_sos_room_name(active_call)
            token = generate_livekit_token(room_name, str(user.id), user.display_name)
            return Response({
                "position": 0,
                "status": "ongoing",
                "sos_id": str(active_call.id),
                "room_name": room_name,
                "livekit_token": token
            })

        # Count calls that should be handled before this one
        position = SOSCall.objects.filter(
            status=SOSCall.Status.WAITING
        ).filter(
            models.Q(priority_score__gt=active_call.priority_score) | 
            models.Q(priority_score=active_call.priority_score, created_at__lt=active_call.created_at)
        ).count() + 1
        
        return Response({
            "position": position,
            "status": "waiting",
            "sos_id": str(active_call.id),
            "priority_score": active_call.priority_score,
            "created_at": active_call.created_at
        })

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
