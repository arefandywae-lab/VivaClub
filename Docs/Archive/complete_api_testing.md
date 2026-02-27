# Viva Club - Complete API Testing Guide (Railway Deployment)

**Base URL:** `https://vivaclub-production.up.railway.app`

> **Note:** Replace `<TOKEN>` with your actual access token from login response.

---

## 📋 Table of Contents
1. [Authentication](#1-authentication)
2. [Ghost Profiles](#2-ghost-profiles)
3. [Rooms (Clubhouse)](#3-rooms-clubhouse)
4. [Following System](#4-following-system)
5. [Notifications](#5-notifications)
6. [Enhanced Discovery](#6-enhanced-discovery)

---

## 1. Authentication

### 1.1 Register Patient
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/auth/register/ \
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

**Expected Response:**
```json
{
  "id": 1,
  "username": "patient1",
  "email": "patient1@example.com",
  "role": "patient",
  "first_name": "Somchai",
  "last_name": "Dee"
}
```

### 1.2 Register Doctor
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/auth/register/ \
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

### 1.3 Login (Get Token)
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "patient1",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**💡 Save the `access` token for all subsequent requests!**

### 1.4 Get Current User Profile
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/auth/me/ \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 2. Ghost Profiles

### 2.1 Get My Ghost Profile
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/ghosts/me/ \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Response:**
```json
{
  "id": "uuid",
  "display_name": "Happy Hippo #123",
  "avatar_url": null,
  "followers_count": 0,
  "is_active": true,
  "role": "patient"
}
```

### 2.2 Update Ghost Profile
```bash
curl -X PATCH https://vivaclub-production.up.railway.app/api/community/ghosts/me/ \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "display_name": "Friendly Ghost #999"
  }'
```

### 2.3 List All Ghost Profiles
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/ghosts/ \
  -H "Authorization: Bearer <TOKEN>"
```

### 2.4 Get Specific Ghost Profile
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/ghosts/<GHOST_ID>/ \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 3. Rooms (Clubhouse)

### 3.1 Create Room
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/rooms/ \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Anxiety Support Group",
    "category": "anxiety",
    "description": "Safe space to talk about anxiety",
    "tags": ["anxiety", "support", "mental-health"]
  }'
```

**Expected Response:**
```json
{
  "id": "uuid",
  "title": "Anxiety Support Group",
  "description": "Safe space to talk about anxiety",
  "tags": ["anxiety", "support", "mental-health"],
  "category": "anxiety",
  "host": "uuid",
  "host_details": {
    "id": "uuid",
    "display_name": "Friendly Ghost #999",
    "followers_count": 0
  },
  "listeners_count": 0,
  "trending_score": 0.0,
  "peak_listeners": 0,
  "is_active": true,
  "created_at": "2026-02-15T09:00:00Z"
}
```

### 3.2 List Active Rooms
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/rooms/ \
  -H "Authorization: Bearer <TOKEN>"
```

### 3.3 Get Room Details
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/rooms/<ROOM_ID>/ \
  -H "Authorization: Bearer <TOKEN>"
```

### 3.4 Join Room (Get LiveKit Token)
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/rooms/<ROOM_ID>/join/ \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Response:**
```json
{
  "room_id": "uuid",
  "title": "Anxiety Support Group",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "url": "wss://vivaclub-c8l1bt1p.livekit.cloud",
  "is_host": false
}
```

### 3.5 Leave Room
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/rooms/<ROOM_ID>/leave/ \
  -H "Authorization: Bearer <TOKEN>"
```

### 3.6 Invite Speaker (Host Only)
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/rooms/<ROOM_ID>/invite/ \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "user-id-to-invite"
  }'
```

---

## 4. Following System

### 4.1 Follow a Ghost
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/ghosts/<GHOST_ID>/follow/ \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Response:**
```json
{
  "message": "Followed successfully",
  "followers_count": 1
}
```

### 4.2 Unfollow a Ghost
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/ghosts/<GHOST_ID>/unfollow/ \
  -H "Authorization: Bearer <TOKEN>"
```

### 4.3 Get My Following List
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/following/ \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Response:**
```json
[
  {
    "id": "uuid",
    "follower": "uuid",
    "target": "uuid",
    "target_details": {
      "id": "uuid",
      "display_name": "Cool Ghost #456",
      "followers_count": 5
    },
    "followed_at": "2026-02-15T08:00:00Z"
  }
]
```

### 4.4 Get Following Feed (Rooms from Followed Ghosts)
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/following/feed/ \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Response:**
```json
{
  "rooms": [
    {
      "id": "uuid",
      "title": "Late Night Chat",
      "host_details": {
        "display_name": "Cool Ghost #456"
      },
      "listeners_count": 3,
      "created_at": "2026-02-15T09:30:00Z"
    }
  ]
}
```

---

## 5. Notifications

### 5.1 Register FCM Token
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/fcm-token/ \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "your-fcm-device-token-here"
  }'
```

### 5.2 Get My Notifications
```bash
curl -X GET https://vivaclub-production.up.railway.app/api/community/notifications/ \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Response:**
```json
{
  "notifications": [
    {
      "id": "uuid",
      "type": "ghost_room_opened",
      "title": "Cool Ghost #456 opened a room",
      "body": "Join 'Late Night Chat' now!",
      "data": {
        "room_id": "uuid",
        "ghost_id": "uuid"
      },
      "is_read": false,
      "created_at": "2026-02-15T09:30:00Z"
    }
  ],
  "unread_count": 1
}
```

### 5.3 Mark Notification as Read
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/notifications/<NOTIFICATION_ID>/mark_read/ \
  -H "Authorization: Bearer <TOKEN>"
```

### 5.4 Mark All as Read
```bash
curl -X POST https://vivaclub-production.up.railway.app/api/community/notifications/mark_all_read/ \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 6. Enhanced Discovery

### 6.1 Get Trending Rooms
```bash
curl -X GET "https://vivaclub-production.up.railway.app/api/community/rooms/trending/?limit=10" \
  -H "Authorization: Bearer <TOKEN>"
```

**Query Parameters:**
- `category` (optional): Filter by category (anxiety, depression, etc.)
- `limit` (optional): Number of rooms (default: 10)

**Expected Response:**
```json
{
  "rooms": [
    {
      "id": "uuid",
      "title": "Anxiety Support Group",
      "description": "Safe space to talk",
      "tags": ["anxiety", "support"],
      "listeners_count": 15,
      "trending_score": 250.0,
      "created_at": "2026-02-15T09:00:00Z"
    }
  ]
}
```

**Trending Algorithm:**
- Score = (listeners × 10) + age_penalty
- age_penalty = max(0, 100 - (minutes_old × 2))
- Newer rooms with more listeners rank higher

### 6.2 Get Trending by Category
```bash
curl -X GET "https://vivaclub-production.up.railway.app/api/community/rooms/trending/?category=anxiety&limit=5" \
  -H "Authorization: Bearer <TOKEN>"
```

### 6.3 Get Scheduled Rooms
```bash
curl -X GET "https://vivaclub-production.up.railway.app/api/community/rooms/scheduled/?upcoming=true" \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Response:**
```json
{
  "rooms": [
    {
      "id": "uuid",
      "title": "Weekly Depression Support",
      "description": "Every Monday at 8 PM",
      "scheduled_at": "2026-02-17T20:00:00Z",
      "is_scheduled": true,
      "is_active": false,
      "host_details": {...}
    }
  ]
}
```

### 6.4 Search Rooms
```bash
curl -X GET "https://vivaclub-production.up.railway.app/api/community/rooms/search/?q=anxiety" \
  -H "Authorization: Bearer <TOKEN>"
```

**Query Parameters:**
- `q` (required): Search query
- `category` (optional): Filter by category

**Expected Response:**
```json
{
  "rooms": [
    {
      "id": "uuid",
      "title": "Anxiety Support Group",
      "description": "Talk about your anxiety",
      "tags": ["anxiety", "support"]
    }
  ],
  "count": 1
}
```

**Search Logic:**
- Searches in: title, description, tags
- Case-insensitive
- Partial match support

### 6.5 Search with Category Filter
```bash
curl -X GET "https://vivaclub-production.up.railway.app/api/community/rooms/search/?q=support&category=anxiety" \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 🧪 Complete Testing Flow

### Step 1: Setup
```bash
# 1. Register a user
curl -X POST https://vivaclub-production.up.railway.app/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser1",
    "password": "test123",
    "email": "test1@example.com",
    "role": "patient"
  }'

# 2. Login and save token
TOKEN=$(curl -X POST https://vivaclub-production.up.railway.app/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser1", "password": "test123"}' \
  | jq -r '.access')

echo "Token: $TOKEN"
```

### Step 2: Test Ghost Profile
```bash
# Get my ghost profile
curl -X GET https://vivaclub-production.up.railway.app/api/community/ghosts/me/ \
  -H "Authorization: Bearer $TOKEN"
```

### Step 3: Test Room Creation
```bash
# Create a room
ROOM_RESPONSE=$(curl -X POST https://vivaclub-production.up.railway.app/api/community/rooms/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Anxiety Room",
    "category": "anxiety",
    "description": "Testing room creation",
    "tags": ["test", "anxiety"]
  }')

ROOM_ID=$(echo $ROOM_RESPONSE | jq -r '.id')
echo "Room ID: $ROOM_ID"
```

### Step 4: Test Join Room
```bash
# Join the room
curl -X POST "https://vivaclub-production.up.railway.app/api/community/rooms/$ROOM_ID/join/" \
  -H "Authorization: Bearer $TOKEN"
```

### Step 5: Test Discovery
```bash
# Get trending rooms
curl -X GET "https://vivaclub-production.up.railway.app/api/community/rooms/trending/?limit=5" \
  -H "Authorization: Bearer $TOKEN"

# Search rooms
curl -X GET "https://vivaclub-production.up.railway.app/api/community/rooms/search/?q=anxiety" \
  -H "Authorization: Bearer $TOKEN"
```

### Step 6: Test Following (Need 2 Users)
```bash
# Register second user
curl -X POST https://vivaclub-production.up.railway.app/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser2",
    "password": "test123",
    "email": "test2@example.com",
    "role": "patient"
  }'

# Login as second user
TOKEN2=$(curl -X POST https://vivaclub-production.up.railway.app/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser2", "password": "test123"}' \
  | jq -r '.access')

# Get user2's ghost ID
GHOST2_ID=$(curl -X GET https://vivaclub-production.up.railway.app/api/community/ghosts/me/ \
  -H "Authorization: Bearer $TOKEN2" | jq -r '.id')

# User1 follows User2
curl -X POST "https://vivaclub-production.up.railway.app/api/community/ghosts/$GHOST2_ID/follow/" \
  -H "Authorization: Bearer $TOKEN"

# Check following list
curl -X GET https://vivaclub-production.up.railway.app/api/community/following/ \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📊 API Endpoints Summary

| Feature | Method | Endpoint | Auth Required |
|---------|--------|----------|---------------|
| **Auth** |
| Register | POST | `/api/auth/register/` | No |
| Login | POST | `/api/auth/login/` | No |
| Get Me | GET | `/api/auth/me/` | Yes |
| **Ghost Profiles** |
| Get My Profile | GET | `/api/community/ghosts/me/` | Yes |
| Update Profile | PATCH | `/api/community/ghosts/me/` | Yes |
| List Ghosts | GET | `/api/community/ghosts/` | Yes |
| Get Ghost | GET | `/api/community/ghosts/<id>/` | Yes |
| Follow | POST | `/api/community/ghosts/<id>/follow/` | Yes |
| Unfollow | POST | `/api/community/ghosts/<id>/unfollow/` | Yes |
| **Rooms** |
| Create Room | POST | `/api/community/rooms/` | Yes |
| List Rooms | GET | `/api/community/rooms/` | Yes |
| Get Room | GET | `/api/community/rooms/<id>/` | Yes |
| Join Room | POST | `/api/community/rooms/<id>/join/` | Yes |
| Leave Room | POST | `/api/community/rooms/<id>/leave/` | Yes |
| Invite Speaker | POST | `/api/community/rooms/<id>/invite/` | Yes |
| Trending | GET | `/api/community/rooms/trending/` | Yes |
| Scheduled | GET | `/api/community/rooms/scheduled/` | Yes |
| Search | GET | `/api/community/rooms/search/` | Yes |
| **Following** |
| Following List | GET | `/api/community/following/` | Yes |
| Following Feed | GET | `/api/community/following/feed/` | Yes |
| **Notifications** |
| List Notifications | GET | `/api/community/notifications/` | Yes |
| Mark Read | POST | `/api/community/notifications/<id>/mark_read/` | Yes |
| Mark All Read | POST | `/api/community/notifications/mark_all_read/` | Yes |
| Register FCM | POST | `/api/community/fcm-token/` | Yes |

---

## 🔍 Troubleshooting

### Common Issues

**1. 401 Unauthorized**
- Token expired or invalid
- Solution: Login again to get a new token

**2. 404 Not Found**
- Wrong endpoint URL
- Check if resource ID exists

**3. 400 Bad Request**
- Missing required fields
- Invalid data format
- Check request body matches expected format

**4. 500 Internal Server Error**
- Server-side error
- Check server logs on Railway dashboard

### Testing Tips

1. **Use `jq` for JSON parsing:**
   ```bash
   curl ... | jq '.'
   ```

2. **Save tokens as variables:**
   ```bash
   TOKEN=$(curl ... | jq -r '.access')
   ```

3. **Test in order:**
   - Auth → Ghost Profile → Rooms → Following → Notifications

4. **Check Railway logs:**
   - Go to Railway dashboard
   - Click on your project
   - View logs for errors

---

## 📝 Notes

- All timestamps are in ISO 8601 format (UTC)
- UUIDs are used for all IDs
- Pagination is available on list endpoints (add `?page=2`)
- Rate limiting may apply (check response headers)

**Last Updated:** 2026-02-15
