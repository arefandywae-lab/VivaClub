# บทที่ 6: API Reference ครบถ้วน
# Chapter 6: Complete API Reference

---

## สารบัญบท / Chapter Contents

6.1 ข้อมูลพื้นฐาน (Base URL & Authentication)  
6.2 Auth Endpoints  
6.3 Community Endpoints  
6.4 Clinical Endpoints  
6.5 Chat Endpoints  
6.6 WebSocket Endpoints  
6.7 Admin Endpoints  
6.8 Webhook Endpoints  

---

## 6.1 ข้อมูลพื้นฐาน

**Base URL:** `https://vivaclubs.site/api/`  
**Content-Type:** `application/json`  
**Authentication:** Bearer JWT Token

```
Authorization: Bearer <access_token>
```

**Error Response Format:**
```json
{
    "error": "Human-readable error message",
    "detail": "Technical detail (optional)"
}
```

**HTTP Status Codes:**
| Code | ความหมาย |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (invalid/missing token) |
| 403 | Forbidden (insufficient permission) |
| 404 | Not Found |
| 500 | Server Error |

---

## 6.2 Auth Endpoints

### `POST /auth/register/`
สมัครบัญชีใหม่

**Permission:** AllowAny  
**Request:**
```json
{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "SecurePass123!",
    "display_name": "John Doe",
    "role": "patient"
}
```
**Response 201:**
```json
{
    "access": "eyJ...",
    "refresh": "eyJ...",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "role": "patient",
    "display_name": "John Doe",
    "is_email_verified": false
}
```

---

### `POST /auth/login/`
เข้าสู่ระบบ (รับ JWT tokens)

**Permission:** AllowAny  
**Request:**
```json
{
    "username": "johndoe",  // หรือ email ก็ได้
    "password": "SecurePass123!"
}
```
**Response 200:**
```json
{
    "access": "eyJ...",
    "refresh": "eyJ...",
    "user_id": "550e8400-...",
    "role": "patient",
    "display_name": "John Doe",
    "is_email_verified": true
}
```

---

### `POST /auth/token/refresh/`
รับ access token ใหม่ด้วย refresh token

**Permission:** AllowAny  
**Request:**
```json
{ "refresh": "eyJ..." }
```
**Response 200:**
```json
{ "access": "eyJ..." }
```

---

### `GET /auth/profile/`
ดูโปรไฟล์ตัวเอง

**Permission:** IsAuthenticated  
**Response 200:**
```json
{
    "id": "550e8400-...",
    "username": "johndoe",
    "email": "john@example.com",
    "display_name": "John Doe",
    "role": "patient",
    "is_email_verified": true,
    "current_mood": "LOW",
    "streak_count": 5,
    "last_assessment_date": "2026-04-24T10:30:00Z",
    "ghost_profile": {
        "id": "ghost-uuid-...",
        "display_name": "Happy Panda #42",
        "followers_count": 12,
        "bio": "Mental health advocate"
    }
}
```

---

### `PUT/PATCH /auth/profile/`
อัปเดตโปรไฟล์

**Permission:** IsAuthenticated  
**Request (PATCH — ส่งเฉพาะ fields ที่ต้องการเปลี่ยน):**
```json
{
    "display_name": "John Updated",
    "phone_number": "+66812345678"
}
```

---

### `POST /auth/verify-email/`
ยืนยัน email ด้วย token ที่รับจาก email

**Permission:** AllowAny  
**Request:**
```json
{ "token": "123456" }
```
**Response 200:**
```json
{ "message": "Email verified successfully." }
```

---

### `POST /auth/forgot-password/`
ขอ reset password (ส่ง email)

**Permission:** AllowAny  
**Request:**
```json
{ "email": "john@example.com" }
```
**Response 200:**
```json
{ "message": "Password reset email sent." }
```

---

### `POST /auth/reset-password/`
ตั้ง password ใหม่

**Permission:** AllowAny  
**Request:**
```json
{
    "token": "reset-token-from-email",
    "new_password": "NewSecurePass123!"
}
```

---

### `POST /auth/device-tokens/`
ลงทะเบียน FCM device token

**Permission:** IsAuthenticated  
**Request:**
```json
{
    "token": "fcm-token-string",
    "device_type": "ios"
}
```

---

## 6.3 Community Endpoints

### `GET /community/ghosts/me/`
ดู Ghost Profile ของตัวเอง

**Response 200:**
```json
{
    "id": "ghost-uuid",
    "display_name": "Happy Panda #42",
    "bio": "Here to support",
    "followers_count": 5,
    "is_active": true
}
```

---

### `PATCH /community/ghosts/me/`
อัปเดต Ghost Profile

**Request:**
```json
{ "bio": "Mental health advocate 💪" }
```

---

### `GET /community/ghosts/{id}/`
ดู Ghost Profile ของ user อื่น

---

### `POST /community/ghosts/{id}/follow/`
ติดตาม Ghost

**Response 200:**
```json
{ "message": "Now following Happy Panda #42" }
```
**Response 400:** Already following

---

### `POST /community/ghosts/{id}/unfollow/`
เลิกติดตาม Ghost

---

### `GET /community/subscriptions/`
รายการ Ghosts ที่ฉันติดตาม

**Response 200:**
```json
[
    {
        "id": "sub-uuid",
        "target": {
            "id": "ghost-uuid",
            "display_name": "Gentle Fox #88",
            "followers_count": 20
        },
        "created_at": "2026-04-01T10:00:00Z"
    }
]
```

---

### `GET /community/subscriptions/feed/`
ดูห้องที่เปิดอยู่จาก Ghosts ที่ติดตาม

**Response 200:**
```json
{
    "rooms": [...],
    "count": 3
}
```

---

### `GET /community/rooms/`
รายการห้องเสียงที่เปิดอยู่

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `search` | string | ค้นหาจากชื่อ/คำอธิบาย |
| `category` | string | general, depression, anxiety, relationships, burnout, sleep |
| `sort` | string | recent (default), trending, scheduled |

**Response 200:**
```json
[
    {
        "id": "room-uuid",
        "title": "Late Night Anxiety Support 🌙",
        "category": "anxiety",
        "host": {
            "id": "ghost-uuid",
            "display_name": "Calm Deer #7"
        },
        "participant_count": 12,
        "listeners_count": 10,
        "is_scheduled": false,
        "trending_score": 8.5,
        "created_at": "2026-04-25T22:00:00Z"
    }
]
```

---

### `POST /community/rooms/`
สร้างห้องใหม่

**Request:**
```json
{
    "title": "Monday Morning Check-in",
    "category": "general",
    "description": "A safe space to start the week",
    "tags": ["morning", "support", "beginner-friendly"]
}
```
**Response 201:** Room object  
**Response 400:** Profanity detected in title

---

### `POST /community/rooms/{id}/join/`
เข้าร่วมห้อง (รับ LiveKit token)

**Response 200:**
```json
{
    "livekit_token": "eyJ...",
    "livekit_url": "wss://livekit.vivaclubs.site",
    "room_id": "room-uuid",
    "role": "listener"
}
```
**Response 403:** Banned from room

---

### `POST /community/rooms/{id}/leave/`
ออกจากห้อง

**Response 200:** `{ "message": "Left room." }`

---

### `POST /community/rooms/{id}/invite/`
เชิญ listener ขึ้นมาเป็น speaker (Host only)

**Request:**
```json
{ "identity": "ghost-id-to-invite" }
```

---

### `POST /community/rooms/{id}/kick-participant/`
Kick participant (Host/Moderator only)

**Request:**
```json
{ "identity": "ghost-id-to-kick" }
```

---

### `POST /community/rooms/{id}/mute-participant/`
Force mute participant (Host/Moderator only)

**Request:**
```json
{
    "identity": "ghost-id",
    "track_sid": "track-id-from-livekit",
    "muted": true
}
```

---

### `GET /community/notifications/`
รายการ in-app notifications

**Response 200:**
```json
[
    {
        "id": "notif-uuid",
        "type": "ghost_room_opened",
        "title": "Happy Panda #42 opened a room",
        "body": "\"Late Night Support\" is now live",
        "data": {"room_id": "room-uuid"},
        "is_read": false,
        "created_at": "2026-04-25T22:00:00Z"
    }
]
```

---

### `PATCH /community/notifications/{id}/mark-read/`
Mark notification as read

---

### `GET /community/trust-score/me/`
ดู Trust Score ของตัวเอง

**Response 200:**
```json
{
    "score": 95,
    "total_reports_received": 1,
    "valid_reports_received": 0,
    "total_reports_made": 2
}
```

---

### `POST /community/reports/`
รายงานผู้ใช้ที่ไม่เหมาะสม

**Request:**
```json
{
    "reported_user": "user-uuid",
    "room": "room-uuid",
    "reason": "harassment",
    "description": "User was verbally aggressive"
}
```
**Reason choices:** harassment, spam, inappropriate, self_harm, other

---

### `POST /community/blocks/`
Block ผู้ใช้

**Request:**
```json
{ "blocked": "user-uuid" }
```

---

### `GET /community/blocks/`
รายการผู้ใช้ที่ถูก block

---

### `DELETE /community/blocks/{id}/`
Unblock ผู้ใช้

---

## 6.4 Clinical Endpoints

### `GET /clinical/assessments/`
รายการ assessments ของตัวเอง

**Response 200:**
```json
[
    {
        "id": "assess-uuid",
        "total_score": 22,
        "risk_level": "SEVERE",
        "answers": {"Q1": 3, "Q2": 2, "Q3": 3, ...},
        "created_at": "2026-04-25T10:00:00Z"
    }
]
```

---

### `POST /clinical/assessments/`
ส่งผลการทำ PHQ-9 assessment

**Request:**
```json
{
    "total_score": 22,
    "answers": {
        "Q1": 3,
        "Q2": 2,
        "Q3": 3,
        "Q4": 2,
        "Q5": 3,
        "Q6": 2,
        "Q7": 3,
        "Q8": 2,
        "Q9": 2
    }
}
```
**Response 201:**
```json
{
    "id": "assess-uuid",
    "total_score": 22,
    "risk_level": "SEVERE",
    "created_at": "2026-04-25T10:00:00Z"
}
```
**Response 400:** ทำไปแล้วภายใน 24 ชั่วโมง

---

### `GET /clinical/doctors/`
รายการแพทย์ที่ verified แล้ว

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `specialty` | string | กรอง specialty เช่น "psychiatry" |
| `is_online` | bool | กรองเฉพาะที่ online อยู่ |
| `search` | string | ค้นหาจากชื่อ/ความเชี่ยวชาญ |

**Response 200:**
```json
[
    {
        "id": "doctor-uuid",
        "display_name": "Dr. Smith",
        "specialty": "Psychiatry",
        "is_online": true,
        "avg_rating": 4.8,
        "review_count": 24
    }
]
```

---

### `POST /clinical/doctors/toggle-online/`
Doctor toggle online/offline status

**Permission:** Doctor role only  
**Response 200:**
```json
{
    "is_online": true,
    "status": "Online"
}
```

---

### `GET /clinical/doctors/dashboard/`
Doctor dashboard stats

**Permission:** Doctor role only  
**Response 200:**
```json
{
    "today_appointments_count": 3,
    "waiting_sos_count": 2,
    "my_stats": {
        "avg_rating": 4.8,
        "review_count": 24
    }
}
```

---

### `GET /clinical/timeslots/?doctor_id={id}`
ดู time slots ที่ว่างของแพทย์

**Response 200:**
```json
[
    {
        "id": "slot-uuid",
        "start_time": "2026-04-26T09:00:00Z",
        "end_time": "2026-04-26T10:00:00Z",
        "price": 1500.00,
        "is_reserved": false
    }
]
```

---

### `POST /clinical/timeslots/`
สร้าง time slot (Doctor only)

**Request:**
```json
{
    "start_time": "2026-04-26T09:00:00Z",
    "end_time": "2026-04-26T10:00:00Z",
    "price": 1500.00
}
```

---

### `GET /clinical/appointments/`
รายการ appointments ของตัวเอง

**Response 200:**
```json
[
    {
        "id": "appt-uuid",
        "patient": {"id": "...", "display_name": "..."},
        "doctor": {"id": "...", "display_name": "Dr. Smith", "specialty": "..."},
        "slot": {
            "start_time": "2026-04-26T09:00:00Z",
            "end_time": "2026-04-26T10:00:00Z",
            "price": 1500.00
        },
        "status": "CONFIRMED",
        "created_at": "2026-04-25T10:00:00Z"
    }
]
```

---

### `POST /clinical/appointments/`
จองนัดหมาย

**Request:**
```json
{ "slot": "slot-uuid" }
```
**Response 201:** Appointment object  
**Response 400:** Slot already reserved (race condition handled)

---

### `POST /clinical/appointments/{id}/confirm/`
Doctor ยืนยัน appointment

**Permission:** Assigned doctor only  
**Response 200:** Updated appointment with status CONFIRMED

---

### `POST /clinical/appointments/{id}/complete/`
Doctor mark appointment as completed

**Response 200:** Updated appointment with status COMPLETED

---

### `POST /clinical/appointments/{id}/join-call/`
ขอ LiveKit token สำหรับ video call

**Response 200:**
```json
{
    "livekit_token": "eyJ...",
    "livekit_url": "wss://livekit.vivaclubs.site",
    "room_name": "appointment_<uuid>"
}
```

---

### `POST /clinical/sos/`
ขอความช่วยเหลือฉุกเฉิน (SOS)

**Permission:** Users with current_mood = SEVERE only  
**Request:** ไม่ต้องส่ง body  
**Response 201:**
```json
{
    "id": "sos-uuid",
    "status": "WAITING",
    "priority_score": 22,
    "queue_position": 3,
    "created_at": "2026-04-25T22:00:00Z"
}
```
**Response 403:** SOS requires SEVERE risk level

---

### `GET /clinical/sos/my_position/`
ผู้ป่วยตรวจสอบ queue position (polling)

**Response — กำลังรอ:**
```json
{
    "status": "waiting",
    "queue_position": 2,
    "priority_score": 22
}
```
**Response — แพทย์รับแล้ว:**
```json
{
    "status": "ongoing",
    "livekit_token": "eyJ...",
    "livekit_url": "wss://livekit.vivaclubs.site",
    "sos_id": "sos-uuid"
}
```
**Response — ไม่มี SOS active:**
```json
{ "status": "no_active_sos" }
```

---

### `GET /clinical/sos/pending/`
Doctor ดู SOS ที่รอ (Priority order)

**Permission:** Doctor role only  
**Response 200:**
```json
[
    {
        "id": "sos-uuid",
        "patient": {"display_name": "Hidden (anonymous)"},
        "priority_score": 27,
        "status": "WAITING",
        "created_at": "2026-04-25T22:00:00Z"
    }
]
```

---

### `POST /clinical/sos/{id}/accept/`
Doctor รับ SOS

**Permission:** Doctor role only  
**Response 200:**
```json
{
    "livekit_token": "eyJ...",
    "livekit_url": "wss://livekit.vivaclubs.site",
    "sos_id": "sos-uuid"
}
```

---

### `POST /clinical/sos/{id}/complete/`
Doctor ปิด SOS call

**Response 200:** `{ "status": "RESOLVED" }`

---

### `GET/POST /clinical/opd-notes/`
Doctor notes (E2EE)

**POST Request:**
```json
{
    "appointment": "appt-uuid",
    "patient": "patient-uuid",
    "encrypted_content": "base64-encrypted-content",
    "iv": "base64-initialization-vector"
}
```

---

### `GET/POST /clinical/personal-notes/`
Patient personal encrypted notes

**POST Request:**
```json
{
    "encrypted_content": "base64-encrypted-content"
}
```

---

### `POST /clinical/appointments/{id}/review/`
Patient รีวิวแพทย์หลังจบ appointment

**Request:**
```json
{
    "rating": 5,
    "comment": "Very understanding and helpful"
}
```

---

## 6.5 Chat Endpoints

### `GET /chat/messages/?room_id={room_id}`
ดู message history

**Query Parameters:** `room_id` (required)  
**Response 200:**
```json
[
    {
        "id": "msg-uuid",
        "sender": {
            "id": "user-uuid",
            "display_name": "John Doe"
        },
        "content": "Hello!",
        "room_id": "dm_uuid1_uuid2",
        "is_redacted": false,
        "created_at": "2026-04-25T22:00:00Z"
    }
]
```

---

### `POST /chat/messages/mark_read/`
Mark messages เป็น read

**Request:**
```json
{ "room_id": "dm_uuid1_uuid2" }
```
**Response 200:**
```json
{ "marked": 5 }
```

---

## 6.6 WebSocket Endpoints

### `WSS /ws/chat/{room_id}/?token={jwt}`
Real-time chat

**Message (Client → Server):**
```json
{ "message": "Hello there!" }
```
**Message (Server → Client):**
```json
{
    "message_id": "msg-uuid",
    "sender_id": "user-uuid",
    "content": "Hello there!",
    "created_at": "2026-04-25T22:00:00Z"
}
```

---

### `WSS /ws/notifications/?token={jwt}`
Real-time in-app notifications

**Message (Server → Client):**
```json
{
    "type": "ghost_room_opened",
    "title": "Happy Panda #42 opened a room",
    "room_id": "room-uuid",
    "ghost_id": "ghost-uuid"
}
```

---

## 6.7 Admin Endpoints

ทุก Admin endpoint ต้องการ `is_staff=True`

### `GET /auth/admin/users/`
รายการ users ทั้งหมด

### `POST /auth/admin/users/{id}/{action}/`
Action: `ban`, `unban`, `promote`, `demote`

### `POST /auth/admin/cleanup-test-data/`
ลบ test data (ใช้ระหว่าง development)

### `POST /auth/admin/test-push/`
ทดสอบ push notification ไปยัง all devices

### `GET /community/reports/`
รายการ reports ทั้งหมด

### `PATCH /community/reports/{id}/validate/`
Admin validate/invalidate report
```json
{ "status": "valid" }
```

### `GET /clinical/appointments/admin-list/`
รายการ appointments ทั้งหมด (paginated)

---

## 6.8 Webhook Endpoints

### `POST /community/webhook/livekit/`
LiveKit webhook — อัปเดต participant counts

**Source:** LiveKit Server (ไม่ใช่ user)  
**Permission:** AllowAny (ตรวจสอบด้วย LiveKit signature)  
**Events handled:** participant_joined, participant_left, room_finished

### `POST /clinical/livekit-webhook/`
LiveKit webhook สำหรับ clinical video calls

**Events handled:** room_finished (complete appointment auto)
