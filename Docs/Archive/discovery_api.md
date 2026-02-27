# Enhanced Room Discovery API Documentation

## Trending Rooms
**Endpoint:** `GET /api/community/rooms/trending/`

**Query Parameters:**
- `category` (optional): Filter by category (general, anxiety, depression, etc.)
- `limit` (optional): Number of rooms to return (default: 10)

**Response:**
```json
{
  "rooms": [
    {
      "id": "uuid",
      "title": "Anxiety Support Group",
      "description": "Safe space to talk about anxiety",
      "tags": ["anxiety", "support", "mental-health"],
      "host_details": {
        "id": "uuid",
        "display_name": "Friendly Ghost",
        "followers_count": 42
      },
      "category": "anxiety",
      "listeners_count": 15,
      "trending_score": 250.0,
      "peak_listeners": 20,
      "created_at": "2026-02-15T10:00:00Z",
      "is_active": true
    }
  ]
}
```

**Trending Algorithm:**
```
Score = (listeners_count × 10) + age_penalty
age_penalty = max(0, 100 - (minutes_since_created × 2))
```
- Newer rooms get higher age_penalty
- More listeners = higher score
- Rooms lose 2 points per minute of age

---

## Scheduled Rooms
**Endpoint:** `GET /api/community/rooms/scheduled/`

**Query Parameters:**
- `upcoming` (optional): Only show future scheduled rooms (default: true)

**Response:**
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

---

## Search Rooms
**Endpoint:** `GET /api/community/rooms/search/`

**Query Parameters:**
- `q` (required): Search query
- `category` (optional): Filter by category

**Response:**
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
- Only returns active rooms

---

## Create Room (Updated)
**Endpoint:** `POST /api/community/rooms/`

**Request:**
```json
{
  "title": "Anxiety Support",
  "category": "anxiety",
  "description": "Safe space to discuss anxiety and coping strategies",
  "tags": ["anxiety", "support", "mental-health", "safe-space"],
  "is_scheduled": false,
  "scheduled_at": null
}
```

**New Fields:**
- `description` (optional): Room description
- `tags` (optional): Array of tags for searchability
- `is_scheduled` (optional): Is this a scheduled room?
- `scheduled_at` (optional): When the room is scheduled (ISO 8601)

**Response:** Same as before, but includes new fields

---

## Testing Examples

### Get Trending Rooms in Anxiety Category
```bash
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8000/api/community/rooms/trending/?category=anxiety&limit=5"
```

### Get Upcoming Scheduled Rooms
```bash
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8000/api/community/rooms/scheduled/?upcoming=true"
```

### Search for "anxiety" Rooms
```bash
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8000/api/community/rooms/search/?q=anxiety"
```

### Create Room with Description and Tags
```bash
curl -X POST -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Late Night Anxiety Chat",
    "category": "anxiety",
    "description": "For those who can'\''t sleep due to anxiety",
    "tags": ["anxiety", "insomnia", "late-night", "support"]
  }' \
  "http://localhost:8000/api/community/rooms/"
```
