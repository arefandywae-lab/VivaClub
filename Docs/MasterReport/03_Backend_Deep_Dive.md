# บทที่ 3: Backend Deep Dive
# Chapter 3: Backend — All 5 Django Apps in Detail

---

## สารบัญบท / Chapter Contents

3.1 โครงสร้าง Django Project  
3.2 App: Users — Authentication & Account Management  
3.3 App: Community — Ghost Profiles & Audio Rooms  
3.4 App: Clinical — Mental Health & Telemedicine  
3.5 App: Bookings — Time Slots & Payments  
3.6 App: Chat — Real-time Messaging  
3.7 ระบบ Cross-App และ Utilities  
3.8 Authentication & Permission System  

---

## 3.1 โครงสร้าง Django Project

```
Server/
├── config/
│   ├── settings.py      ← Main Django configuration
│   ├── urls.py          ← Root URL routing
│   ├── asgi.py          ← ASGI + WebSocket routing
│   └── wsgi.py          ← WSGI (ไม่ใช้ใน production, ใช้ Daphne แทน)
├── apps/
│   ├── users/           ← Authentication, profiles, device tokens
│   ├── community/       ← Ghost profiles, rooms, notifications, safety
│   ├── clinical/        ← PHQ-9, doctors, appointments, SOS, notes
│   ├── bookings/        ← Time slot management (merged into clinical)
│   ├── chat/            ← Real-time messaging (WebSocket + REST)
│   └── utils/           ← Shared utilities (notifications, LiveKit helpers)
├── templates/           ← Email templates
├── manage.py
└── requirements.txt
```

### INSTALLED_APPS Order (สำคัญ!)

```python
INSTALLED_APPS = [
    'daphne',                        # ← ต้องอยู่ก่อน staticfiles เพื่อ override ASGI
    'django.contrib.admin',
    'django.contrib.auth',
    # ... django core apps ...
    
    # Third party
    'rest_framework',
    'corsheaders',
    'channels',
    'django_q',
    'cloudinary_storage',
    'cloudinary',
    
    # Local apps
    'apps.users',
    'apps.bookings',
    'apps.clinical',
    'apps.community',
    'apps.chat',
]
```

**ทำไม `daphne` ต้องอยู่ก่อน staticfiles:** Daphne ต้อง override Django's built-in `runserver` command เพื่อ run ASGI server แทน WSGI เมื่อ development ถ้าอยู่หลัง staticfiles จะไม่สามารถ override ได้

### Key Settings

```python
# Custom User Model
AUTH_USER_MODEL = 'users.User'

# Default permission — ต้อง authenticated ทุก endpoint
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

# JWT Configuration — 30 day access token
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=60),
    'ALGORITHM': 'HS256',
}
```

---

## 3.2 App: Users

### วัตถุประสงค์
จัดการ authentication, profiles, email verification, password reset, device tokens สำหรับ push notifications

### Custom User Model

```python
# apps/users/models.py
class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    class Role(models.TextChoices):
        PATIENT = 'patient'
        DOCTOR = 'doctor'
        ADMIN = 'admin'

    role = models.CharField(max_length=10, choices=Role.choices, default=Role.PATIENT)
    
    # Identity
    display_name = models.CharField(max_length=255, blank=True, null=True)
    phone_number = models.CharField(max_length=15, unique=True, blank=True, null=True)
    
    # Doctor-specific fields
    license_id = models.CharField(max_length=50, blank=True, null=True)
    specialty = models.CharField(max_length=100, blank=True, null=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    
    # Email verification
    is_email_verified = models.BooleanField(default=False)
    email_verification_token = models.CharField(max_length=100, blank=True, null=True)
    
    # Status
    is_online = models.BooleanField(default=False)  # Doctor shift toggle
    
    # Clinical gamification
    current_mood = models.CharField(max_length=20, default='UNKNOWN')
    streak_count = models.IntegerField(default=0)
    last_assessment_date = models.DateTimeField(null=True, blank=True)
```

### Custom JWT Serializer

เพิ่ม fields พิเศษใน JWT response:

```python
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data['user_id'] = str(self.user.id)
        data['role'] = self.user.role
        data['display_name'] = self.user.display_name
        data['is_email_verified'] = self.user.is_email_verified
        return data
```

Flutter ใช้ข้อมูลเหล่านี้เพื่อ route user ไปยัง portal ที่ถูกต้อง (patient vs doctor) โดยไม่ต้องเรียก `/api/auth/profile/` อีกครั้ง

### Email Verification Flow

```
1. User สมัคร → Django สร้าง email_verification_token (random 6-digit code)
2. Django ส่ง email ผ่าน SMTP (Gmail App Password)
3. User ได้รับ email → กรอก code ใน app
4. POST /api/auth/verify-email/ {token: "123456"}
   → Django ตรวจสอบ → set is_email_verified = True
```

### Forgot Password Flow

```
1. POST /api/auth/forgot-password/ {email: "user@example.com"}
   → Django สร้าง reset token, ส่ง email พร้อม link
2. User คลิก link ใน email → เปิด deep link ใน app
3. POST /api/auth/reset-password/ {token: "...", new_password: "..."}
   → Django verify token → hash password → clear token
```

### Admin User Management

```python
# POST /api/auth/admin/users/{id}/{action}/
# action: ban, unban, promote (to doctor), demote (to patient)
@action(detail=True, methods=['post'], url_path='(?P<action>ban|unban|promote|demote)')
def user_action(self, request, pk=None, action=None):
    user = self.get_object()
    if action == 'ban':
        user.is_active = False
    elif action == 'unban':
        user.is_active = True
    elif action == 'promote':
        user.role = User.Role.DOCTOR
    elif action == 'demote':
        user.role = User.Role.PATIENT
    user.save()
    return Response({"status": f"User {action}ned successfully"})
```

---

## 3.3 App: Community

### วัตถุประสงค์
จัดการ Ghost Profiles (anonymous identities), Clubhouse-style Audio Rooms, Follow system, Notifications, Trust Score, Safety features

### Ghost Profile System

Ghost Profile สร้างอัตโนมัติเมื่อ User ลงทะเบียน ชื่อ Ghost สร้างจาก `ghost_names.py`:

```python
# apps/utils/ghost_names.py
ADJECTIVES = ["Happy", "Gentle", "Brave", "Calm", "Kind", ...]  # 24 adjectives
ANIMALS = ["Panda", "Fox", "Otter", "Deer", "Whale", ...]  # 150+ animals

def generate_ghost_name() -> str:
    adj = random.choice(ADJECTIVES)
    animal = random.choice(ANIMALS)
    number = random.randint(1, 999)
    return f"{adj} {animal} #{number}"
    # ผลลัพธ์เช่น: "Happy Panda #42", "Gentle Fox #158"
```

**ทำไมชื่อ Ghost สำคัญ:**
- ไม่ใช่ชื่อจริง → ป้องกัน stigma
- Format ที่ recognize ได้ → ง่ายต่อการจำและพูดถึงในห้องเสียง
- ไม่มีรูปถ่าย → emoji avatar แทน (generate จากชื่อสัตว์)

### Room Views — Business Logic สำคัญ

```python
class RoomViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        queryset = Room.objects.filter(is_active=True).select_related('host')
        
        # Profanity filter on search
        search = self.request.query_params.get('search', '')
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) | Q(description__icontains=search)
            )
        
        # Category filter
        category = self.request.query_params.get('category')
        if category:
            queryset = queryset.filter(category=category)
        
        # Sorting
        sort = self.request.query_params.get('sort', 'recent')
        if sort == 'trending':
            queryset = queryset.order_by('-trending_score', '-participant_count')
        elif sort == 'scheduled':
            queryset = queryset.filter(is_scheduled=True).order_by('scheduled_at')
        else:  # recent
            queryset = queryset.order_by('-created_at')
        
        return queryset

    def perform_create(self, serializer):
        # Profanity check on title
        title = serializer.validated_data.get('title', '')
        for word in BANNED_WORDS:
            if word.lower() in title.lower():
                raise serializers.ValidationError("Room title contains inappropriate content.")
        
        ghost_profile = get_object_or_404(GhostProfile, user=self.request.user)
        room = serializer.save(host=ghost_profile)
        
        # Notify followers
        NotificationService.send_ghost_room_notification(ghost_profile, room)
```

```python
    @action(detail=True, methods=['post'])
    def join(self, request, pk=None):
        room = self.get_object()
        
        # Check if banned from this room
        if room.banned_users.filter(id=request.user.id).exists():
            return Response({"error": "You are banned from this room."}, status=403)
        
        ghost_profile = get_object_or_404(GhostProfile, user=request.user)
        is_host = (ghost_profile == room.host)
        
        # Determine role
        role = "host" if is_host else "listener"
        can_publish = is_host  # Only host can speak initially
        
        # Generate LiveKit token with metadata
        metadata = {
            "ghost_id": str(ghost_profile.id),
            "display_name": ghost_profile.display_name,
            "role": role,
            "is_host": is_host,
            "handRaised": False,
        }
        
        token = generate_livekit_token(
            room_name=str(room.id),
            identity=str(ghost_profile.id),
            metadata=metadata,
            can_publish=can_publish,
        )
        
        return Response({
            "livekit_token": token,
            "livekit_url": settings.LIVEKIT_URL,
            "room_id": str(room.id),
            "role": role,
        })
```

### LiveKit Webhook Handler

```python
@api_view(['POST'])
@permission_classes([AllowAny])  # LiveKit ส่งมาโดยไม่ได้ auth
def livekit_webhook(request):
    event_type = request.data.get('event')
    room_name = request.data.get('room', {}).get('name')
    
    try:
        room = Room.objects.get(id=room_name)
    except Room.DoesNotExist:
        return Response(status=200)  # ไม่ error, แค่ ignore
    
    if event_type == 'participant_joined':
        room.participant_count = models.F('participant_count') + 1
        room.peak_listeners = models.Case(
            models.When(peak_listeners__lt=models.F('participant_count'), 
                       then=models.F('participant_count')),
            default=models.F('peak_listeners')
        )
    elif event_type == 'participant_left':
        room.participant_count = models.Greatest(
            models.F('participant_count') - 1, 0
        )
    elif event_type == 'room_finished':
        room.is_active = False
    
    room.save()
    return Response(status=200)
```

### NotificationService

```python
# apps/community/services.py
class NotificationService:
    @staticmethod
    def send_ghost_room_notification(ghost_profile: GhostProfile, room: Room):
        """Notify followers when a ghost opens a new room"""
        followers = GhostSubscription.objects.filter(
            target=ghost_profile
        ).select_related('follower__user')
        
        for subscription in followers:
            follower_user = subscription.follower.user
            
            # Create in-app notification
            Notification.objects.create(
                user=follower_user,
                type='ghost_room_opened',
                title=f"{ghost_profile.display_name} opened a room",
                body=f'"{room.title}" is now live',
                data={"room_id": str(room.id), "ghost_id": str(ghost_profile.id)}
            )
            
            # Push notification via FCM
            send_push_notification(
                user=follower_user,
                title=f"{ghost_profile.display_name} is live",
                body=f'"{room.title}"',
                data={"room_id": str(room.id), "type": "ghost_room_opened"}
            )
            
            # WebSocket real-time notification
            async_to_sync(channel_layer.group_send)(
                f"user_{follower_user.id}",
                {
                    "type": "notification.message",
                    "data": {
                        "type": "ghost_room_opened",
                        "room_id": str(room.id),
                        "ghost_id": str(ghost_profile.id),
                    }
                }
            )
```

### Trust Score System

```python
# เมื่อ admin validate report เป็น "valid"
def validate_report(report: RoomReport):
    report.status = 'valid'
    report.resolved_at = timezone.now()
    
    # Penalize reported user
    trust_score, _ = UserTrustScore.objects.get_or_create(user=report.reported_user)
    trust_score.score = max(0, trust_score.score - 10)  # ลด 10 คะแนน
    trust_score.valid_reports_received += 1
    trust_score.save()
    
    # Reward reporter
    reporter_score, _ = UserTrustScore.objects.get_or_create(user=report.reporter)
    reporter_score.score = min(200, reporter_score.score + 2)  # เพิ่ม 2 คะแนน
    reporter_score.save()
```

---

## 3.4 App: Clinical

### วัตถุประสงค์
PHQ-9 mental health assessment, doctor discovery & booking, video consultation, SOS emergency triage, encrypted clinical notes

### PHQ-9 Assessment — Business Logic

```python
class AssessmentViewSet(viewsets.ModelViewSet):
    @transaction.atomic
    def perform_create(self, serializer):
        user = self.request.user
        now = timezone.now()
        
        # ① 24-hour cooldown check
        if user.last_assessment_date:
            if now - user.last_assessment_date < timezone.timedelta(hours=24):
                raise serializers.ValidationError(
                    "You can only take the assessment once every 24 hours."
                )
        
        # ② Save assessment
        assessment = serializer.save(patient=user)
        
        # ③ Update user's current mood
        user.current_mood = assessment.risk_level  # LOW / MODERATE / SEVERE
        
        # ④ Streak calculation
        if user.last_assessment_date:
            hours_since_last = (now - user.last_assessment_date).total_seconds() / 3600
            if hours_since_last < 48:
                # ทำภายใน 48 ชั่วโมง = streak ต่อเนื่อง
                user.streak_count += 1
            else:
                # หยุดเกิน 48 ชั่วโมง = reset streak
                user.streak_count = 1
        else:
            user.streak_count = 1  # ครั้งแรก
        
        user.last_assessment_date = now
        user.save()
```

**PHQ-9 Scoring Logic (ใน Flutter, ส่งมาเป็น total_score):**
```
Score 0–9   → risk_level = 'LOW'     → แนะนำ Community
Score 10–18 → risk_level = 'MODERATE' → แนะนำ Doctor booking
Score 19–27 → risk_level = 'SEVERE'   → ปลดล็อค SOS button
```

### Doctor Discovery

```python
class DoctorViewSet(viewsets.ReadOnlyModelViewSet):
    def get_queryset(self):
        # เฉพาะแพทย์ที่ verified แล้ว
        queryset = User.objects.filter(
            role=User.Role.DOCTOR,
            verified_at__isnull=False
        ).annotate(
            avg_rating=models.Avg('reviews__rating'),
            review_count=models.Count('reviews', distinct=True)
        )
        
        # Filter by specialty
        specialty = self.request.query_params.get('specialty')
        if specialty:
            queryset = queryset.filter(specialty__icontains=specialty)
        
        # Filter by online status
        is_online = self.request.query_params.get('is_online')
        if is_online:
            queryset = queryset.filter(is_online=is_online.lower() == 'true')
        
        return queryset
```

### Appointment Booking — Race Condition Prevention

```python
class AppointmentViewSet(viewsets.ModelViewSet):
    @transaction.atomic
    def perform_create(self, serializer):
        slot_id = self.request.data.get('slot')
        
        # SELECT FOR UPDATE — lock row ป้องกัน concurrent booking
        slot = TimeSlot.objects.select_for_update().get(id=slot_id)
        
        if slot.is_reserved:
            raise serializers.ValidationError("This slot is already reserved.")
        
        # Mark as reserved atomically
        slot.is_reserved = True
        slot.save()
        
        # Create appointment
        appointment = serializer.save(
            patient=self.request.user,
            doctor=slot.doctor,
        )
        
        # Notify doctor
        send_push_notification(
            user=slot.doctor,
            title="New Booking Request",
            body=f"Patient requested slot for {slot.start_time:%Y-%m-%d %H:%M}"
        )
```

**`select_for_update()` คืออะไร:** Database-level row locking — ถ้า 2 users พยายาม book slot เดียวกันพร้อมกัน คนที่สองจะรอ lock release ก่อน จากนั้น check `is_reserved` จะเห็นว่า `True` แล้วและ raise error — ไม่มี double-booking

### SOS Emergency System

```python
class SOSCallViewSet(viewsets.ModelViewSet):
    def perform_create(self, serializer):
        user = self.request.user
        
        # ① ตรวจสอบว่า user มี SEVERE risk หรือไม่
        if user.current_mood != 'SEVERE':
            raise permissions.PermissionDenied(
                "SOS is only available for users with SEVERE risk level. "
                "Please complete the assessment first."
            )
        
        # ② หา PHQ-9 score ล่าสุด สำหรับ priority
        latest_assessment = Assessment.objects.filter(
            patient=user
        ).order_by('-created_at').first()
        
        priority_score = latest_assessment.total_score if latest_assessment else 19
        
        # ③ สร้าง SOS call
        sos = serializer.save(
            patient=user,
            priority_score=priority_score,
            status=SOSCall.Status.WAITING
        )
        
        # ④ แจ้งแพทย์ทุกคนที่ online
        notify_sos_to_doctors(sos)
    
    @action(detail=False, methods=['get'], url_path='my_position')
    def my_position(self, request):
        """ผู้ป่วย polling ดู queue position และ status"""
        sos = SOSCall.objects.filter(
            patient=request.user,
            status__in=[SOSCall.Status.WAITING, SOSCall.Status.ONGOING]
        ).first()
        
        if not sos:
            return Response({"status": "no_active_sos"})
        
        if sos.status == SOSCall.Status.ONGOING:
            # แพทย์รับแล้ว — คืน room credentials
            room_name = f"sos_{sos.id}"
            token = generate_livekit_token(
                room_name=room_name,
                identity=str(request.user.id),
                metadata={"role": "patient"},
                can_publish=True,
            )
            return Response({
                "status": "ongoing",
                "livekit_token": token,
                "livekit_url": settings.LIVEKIT_URL,
                "sos_id": str(sos.id),
            })
        
        # ยังรอ — คืน queue position
        position = SOSCall.objects.filter(
            status=SOSCall.Status.WAITING,
            created_at__lt=sos.created_at  # คนที่รอก่อนหน้า
        ).count() + 1
        
        return Response({
            "status": "waiting",
            "queue_position": position,
            "priority_score": sos.priority_score,
        })
```

**Flutter polls `/my_position` ทุก 5 วินาที:** เมื่อ status เปลี่ยนเป็น `ongoing` Flutter navigate ไปยัง video call screen อัตโนมัติ

### Doctor SOS Accept

```python
    @action(detail=True, methods=['post'], url_path='accept')
    def accept(self, request, pk=None):
        if request.user.role != User.Role.DOCTOR:
            return Response({"error": "Only doctors can accept SOS."}, status=403)
        
        sos = self.get_object()
        if sos.status != SOSCall.Status.WAITING:
            return Response({"error": "SOS is no longer available."}, status=400)
        
        # Assign doctor and update status
        sos.assigned_doctor = request.user
        sos.status = SOSCall.Status.ONGOING
        sos.save()
        
        # Generate doctor's LiveKit token
        room_name = f"sos_{sos.id}"
        token = generate_livekit_token(
            room_name=room_name,
            identity=str(request.user.id),
            metadata={"role": "doctor"},
            can_publish=True,
        )
        
        return Response({
            "livekit_token": token,
            "livekit_url": settings.LIVEKIT_URL,
            "sos_id": str(sos.id),
        })
```

### E2EE Clinical Notes

```python
class OpdNoteViewSet(viewsets.ModelViewSet):
    def perform_create(self, serializer):
        # Server เก็บแค่ ciphertext + IV
        # ไม่มี key ที่ server — decrypt ได้เฉพาะ client ที่มี key
        serializer.save(
            doctor=self.request.user,
            # encrypted_content และ iv มาจาก client แล้ว
        )
    
    def get_queryset(self):
        user = self.request.user
        if user.role == User.Role.DOCTOR:
            # Doctor เห็นเฉพาะ notes ที่ตัวเองเขียน
            return OpdNote.objects.filter(doctor=user)
        elif user.role == User.Role.PATIENT:
            # Patient เห็น notes ที่เกี่ยวกับตัวเอง
            return OpdNote.objects.filter(patient=user)
        return OpdNote.objects.none()
```

---

## 3.5 App: Bookings

App นี้ถูก refactor และ merge เข้า Clinical app ในระหว่างการพัฒนา เนื่องจาก TimeSlot และ Appointment มีความสัมพันธ์แน่นกับ clinical workflow มากกว่า booking workflow ที่แยกจากกัน

ปัจจุบัน `apps/bookings/` มี models และ views พื้นฐาน แต่ฟีเจอร์หลักทั้งหมดอยู่ใน `apps/clinical/`

---

## 3.6 App: Chat

### วัตถุประสงค์
Real-time 1-on-1 และ group messaging ผ่าน WebSocket พร้อม message history และ read receipts

### REST API (Message History)

```python
class MessageViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        room_id = self.request.query_params.get('room_id')
        if not room_id:
            return Message.objects.none()
        
        # Security: verify user can access this room
        if room_id.startswith('dm_'):
            parts = room_id.split('_')
            user_ids = parts[1:]
            if str(self.request.user.id) not in user_ids:
                return Message.objects.none()
        
        return Message.objects.filter(
            room_id=room_id
        ).select_related('sender').order_by('created_at')[:100]  # Last 100 messages
    
    @action(detail=False, methods=['post'], url_path='mark_read')
    def mark_read(self, request):
        room_id = request.data.get('room_id')
        messages = Message.objects.filter(room_id=room_id).exclude(sender=request.user)
        
        for message in messages:
            ReadReceipt.objects.get_or_create(message=message, user=request.user)
        
        return Response({"marked": messages.count()})
```

---

## 3.7 ระบบ Cross-App และ Utilities

### Push Notifications (`apps/utils/notifications.py`)

```python
def send_push_notification(user, title: str, body: str, data: dict = None):
    """ส่ง FCM push notification ไปยัง device tokens ของ user"""
    device_tokens = DeviceToken.objects.filter(user=user).values_list('token', flat=True)
    
    if not device_tokens:
        return
    
    message = messaging.MulticastMessage(
        tokens=list(device_tokens),
        notification=messaging.Notification(title=title, body=body),
        data=data or {},
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(sound="default")
            )
        )
    )
    
    response = messaging.send_multicast(message)
    
    # ลบ invalid tokens
    if response.failure_count > 0:
        for idx, result in enumerate(response.responses):
            if not result.success:
                DeviceToken.objects.filter(token=list(device_tokens)[idx]).delete()
```

### Appointment Reminder Task (`apps/clinical/tasks.py`)

```python
# Django-Q scheduled task
def send_appointment_reminders():
    """Run every 15 minutes via Django-Q cron"""
    now = timezone.now()
    reminder_time = now + timedelta(minutes=15)
    
    upcoming = Appointment.objects.filter(
        status=Appointment.Status.CONFIRMED,
        slot__start_time__range=(now, reminder_time),
        reminder_sent=False
    )
    
    for appointment in upcoming:
        # Remind patient
        send_push_notification(
            user=appointment.patient,
            title="Upcoming Appointment",
            body=f"Your appointment with {appointment.doctor.display_name} starts in 15 minutes"
        )
        appointment.reminder_sent = True
        appointment.save()
```

---

## 3.8 Authentication & Permission System

### Permission Layers

| Layer | Description | Implementation |
|-------|-------------|----------------|
| **IsAuthenticated** | ต้อง login (มี valid JWT) | Django REST default |
| **IsAdminUser** | ต้องเป็น staff (is_staff=True) | Django built-in |
| **AllowAny** | ไม่ต้อง auth | ใช้บน login/register เท่านั้น |
| **Role check** | ต้องเป็น role เฉพาะ | Custom check ใน view |

### Public Endpoints (AllowAny)

```python
class PublicTokenObtainPairView(TokenObtainPairView):
    permission_classes = [AllowAny]  # ← CRITICAL: override default IsAuthenticated
    serializer_class = CustomTokenObtainPairSerializer

class RegisterView(generics.CreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = UserRegistrationSerializer
```

**ทำไมต้อง explicit `AllowAny`:** Global default คือ `IsAuthenticated` — ถ้าไม่ override, login/register endpoint จะ return 401 สำหรับ user ใหม่ (bug ที่พบจริงระหว่าง deployment แรก)

### Role-based Access Examples

```python
# Doctor-only endpoint
@action(detail=False, methods=['post'])
def toggle_online(self, request):
    if request.user.role != User.Role.DOCTOR:
        return Response({"error": "Only doctors."}, status=403)
    # ...

# Patient-only SOS
def perform_create(self, serializer):  # SOSCallViewSet
    if request.user.current_mood != 'SEVERE':
        raise PermissionDenied("SOS requires SEVERE risk level.")
    # ...

# Admin-only endpoint
class AdminUserView(generics.ListAPIView):
    permission_classes = [IsAdminUser]
    # ...
```

### Custom Auth Backend

```python
# apps/users/backends.py
class EmailOrUsernameModelBackend(ModelBackend):
    """Login with either username OR email"""
    def authenticate(self, request, username=None, password=None, **kwargs):
        UserModel = get_user_model()
        try:
            # Try email first
            user = UserModel.objects.get(email=username)
        except UserModel.DoesNotExist:
            try:
                # Fallback to username
                user = UserModel.objects.get(username=username)
            except UserModel.DoesNotExist:
                return None
        
        if user.check_password(password):
            return user
        return None
```
