# Anonymous Subscription API Documentation

## Base URL
```
http://localhost:8000/api/community
```

---

## 1. Follow Ghost Profile

**Endpoint:** `POST /ghosts/{ghost_id}/follow/`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "message": "Now following Happy Panda"
}
```

**Status Codes:**
- `200 OK` - Successfully followed or already following
- `400 Bad Request` - Cannot follow yourself
- `404 Not Found` - Ghost not found

---

## 2. Unfollow Ghost Profile

**Endpoint:** `POST /ghosts/{ghost_id}/unfollow/`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "message": "Unfollowed Happy Panda"
}
```

---

## 3. Get Following List

**Endpoint:** `GET /following/`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "follower": "uuid",
    "target": "uuid",
    "target_details": {
      "id": "uuid",
      "display_name": "Happy Panda",
      "avatar_url": "https://...",
      "followers_count": 42,
      "is_active": true,
      "role": "patient"
    },
    "followed_at": "2026-02-15T10:00:00Z",
    "created_at": "2026-02-15T10:00:00Z"
  }
]
```

---

## 4. Get Following Feed

**Endpoint:** `GET /following/feed/`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "rooms": [
    {
      "id": "uuid",
      "title": "Anxiety Support",
      "host": "uuid",
      "host_details": {
        "id": "uuid",
        "display_name": "Happy Panda",
        "avatar_url": "https://...",
        "followers_count": 42,
        "is_active": true,
        "role": "patient"
      },
      "category": "anxiety",
      "listeners_count": 15,
      "last_active_at": "2026-02-15T10:00:00Z",
      "is_active": true,
      "created_at": "2026-02-15T10:00:00Z"
    }
  ],
  "count": 1
}
```

---

## 5. Register FCM Token

**Endpoint:** `POST /fcm-token/`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "token": "fcm_device_token_string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "FCM token registered"
}
```

---

## 6. Get Notifications

**Endpoint:** `GET /notifications/`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "notifications": [
    {
      "id": "uuid",
      "type": "ghost_room_opened",
      "title": "Happy Panda opened a room",
      "body": "Join 'Anxiety Support' now!",
      "data": {
        "room_id": "uuid",
        "ghost_id": "uuid",
        "room_title": "Anxiety Support"
      },
      "is_read": false,
      "created_at": "2026-02-15T10:00:00Z"
    }
  ],
  "unread_count": 5
}
```

---

## 7. Mark Notification as Read

**Endpoint:** `POST /notifications/{notification_id}/read/`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true
}
```

---

## 8. Mark All Notifications as Read

**Endpoint:** `POST /notifications/read-all/`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true
}
```

---

## Notification Types

| Type | Description | Data Fields |
|------|-------------|-------------|
| `ghost_room_opened` | Followed ghost opened a room | `room_id`, `ghost_id`, `room_title` |
| `hand_raise_accepted` | Your hand raise was accepted | `room_id`, `room_title` |
| `room_invite` | You were invited to speak | `room_id`, `room_title` |

---

## Testing with cURL

### Follow a ghost
```bash
curl -X POST http://localhost:8000/api/community/ghosts/{ghost_id}/follow/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get following list
```bash
curl http://localhost:8000/api/community/following/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get following feed
```bash
curl http://localhost:8000/api/community/following/feed/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Register FCM token
```bash
curl -X POST http://localhost:8000/api/community/fcm-token/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"token": "fcm_device_token"}'
```

### Get notifications
```bash
curl http://localhost:8000/api/community/notifications/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```
