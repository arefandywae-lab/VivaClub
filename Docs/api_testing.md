# API Verification Guide

This guide details how to manually test the Viva Club Backend APIs using `curl` or Postman.

## 1. Authentication Flow

### Register a Patient
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "patient1",
    "password": "password123",
    "email": "patient1@example.com",
    "role": "patient",
    "first_name": "Somchai",
    "last_name": "Dee"
  }'
```

### Register a Doctor
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "doctor1",
    "password": "password123",
    "email": "doctor1@example.com",
    "role": "doctor",
    "license_id": "MD12345",
    "specialty": "Psychiatrist"
  }'
```

### Login (Get Token)
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "patient1",
    "password": "password123"
  }'
```
**Response**:
```json
{
  "refresh": "eyJ0...",
  "access": "eyJ0..." 
}
```
*Save the `access` token for subsequent requests as `Bearer <token>`.*

---

## 2. Booking Flow

### Create Appointment Slot (As Doctor)
*Requires Doctor Token*
```bash
curl -X POST http://localhost:8000/api/bookings/slots/ \
  -H "Authorization: Bearer <DOCTOR_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "start_time": "2024-12-01T10:00:00Z",
    "end_time": "2024-12-01T11:00:00Z",
    "cost": "500.00"
  }'
```

### List Available Slots (As Patient)
*Requires Patient Token*
```bash
curl -X GET http://localhost:8000/api/bookings/slots/ \
  -H "Authorization: Bearer <PATIENT_TOKEN>"
```

### Reserve a Slot (As Patient)
```bash
curl -X POST http://localhost:8000/api/bookings/slots/{SLOT_ID}/reserve/ \
  -H "Authorization: Bearer <PATIENT_TOKEN>"
```

### Confirm Booking (Mock Payment)
```bash
curl -X POST http://localhost:8000/api/bookings/slots/{SLOT_ID}/confirm/ \
  -H "Authorization: Bearer <PATIENT_TOKEN>"
```

---

## 3. LiveKit Media (Video/Audio)

### Generate Join Token
Use this to get a token for joining a video call or audio room.
```bash
curl -X POST http://localhost:8000/api/community/livekit/token/ \
  -H "Authorization: Bearer <USER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "room_name": "room-123"
  }'
```
**Response**:
```json
{
  "token": "eyJ...",
  "room_name": "room-123",
  "identity": "patient1"
}
```

### Test Connection
1. Go to [LiveKit Connection Tester](https://livekit.io/connection-test).
2. Enter your LiveKit Server URL (e.g., `wss://your-project.livekit.cloud`).
3. Paste the `token` generated above.
4. Click **Connect**. You should see your camera/audio active.

---

## 4. Community (Clubhouse)

### Get My Ghost Profile
```bash
curl -X GET http://localhost:8000/api/community/ghosts/me/ \
  -H "Authorization: Bearer <USER_TOKEN>"
```

### Update Ghost Avatar
```bash
curl -X PATCH http://localhost:8000/api/community/ghosts/me/ \
  -H "Authorization: Bearer <USER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "display_name": "Happy Hippo #999",
    "avatar_url": "https://example.com/avatar.png"
  }'
```
