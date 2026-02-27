# Enhanced Room Discovery - Backend Implementation Summary

## ✅ Completed

### 1. Database Schema
**File:** `Server/apps/community/models.py`

Added 6 new fields to `Room` model:
```python
# Enhanced Discovery Fields
description = models.TextField(blank=True, default='')
tags = models.JSONField(default=list)
scheduled_at = models.DateTimeField(null=True, blank=True)
is_scheduled = models.BooleanField(default=False)
trending_score = models.FloatField(default=0.0)
peak_listeners = models.IntegerField(default=0)
```

### 2. Serializer
**File:** `Server/apps/community/serializers.py`

Updated `RoomSerializer` to include all new fields in `fields` and `read_only_fields`.

### 3. Migration
**File:** `Server/apps/community/migrations/0006_room_description_room_is_scheduled_and_more.py`

Created migration for 6 new fields (ready to apply).

### 4. API Documentation
**File:** `Docs/discovery_api.md`

Documented 3 new endpoints with examples and testing commands.

---

## 🔧 TODO: Manual Steps Required

### Step 1: Add Endpoints to views.py

**File:** `Server/apps/community/views.py`

Add these 3 methods to `RoomViewSet` class (before `NotificationViewSet` at line 283):

```python
@decorators.action(detail=False, methods=['get'], url_path='trending')
def trending(self, request):
    \"\"\"Get trending rooms sorted by trending score\"\"\"
    from django.utils import timezone
    
    category = request.query_params.get('category')
    limit = int(request.query_params.get('limit', 10))
    
    # Calculate trending score for active rooms
    now = timezone.now()
    rooms = Room.objects.filter(is_active=True)
    
    if category and category != 'general':
        rooms = rooms.filter(category=category)
    
    # Calculate trending score
    for room in rooms:
        minutes_old = (now - room.created_at).total_seconds() / 60
        age_penalty = max(0, 100 - (minutes_old * 2))
        room.trending_score = (room.listeners_count * 10) + age_penalty
        room.save(update_fields=['trending_score'])
    
    # Get top trending
    trending_rooms = rooms.order_by('-trending_score')[:limit]
    serializer = RoomSerializer(trending_rooms, many=True)
    
    return Response({'rooms': serializer.data})

@decorators.action(detail=False, methods=['get'], url_path='scheduled')
def scheduled(self, request):
    \"\"\"Get scheduled rooms\"\"\"
    from django.utils import timezone
    
    upcoming = request.query_params.get('upcoming', 'true') == 'true'
    
    rooms = Room.objects.filter(is_scheduled=True)
    
    if upcoming:
        rooms = rooms.filter(scheduled_at__gte=timezone.now())
    
    rooms = rooms.order_by('scheduled_at')
    serializer = RoomSerializer(rooms, many=True)
    
    return Response({'rooms': serializer.data})

@decorators.action(detail=False, methods=['get'], url_path='search')
def search(self, request):
    \"\"\"Search rooms by title, description, tags\"\"\"
    from django.db.models import Q
    
    query = request.query_params.get('q', '').strip()
    category = request.query_params.get('category')
    
    if not query:
        return Response({'rooms': [], 'count': 0})
    
    # Search in title, description, tags
    rooms = Room.objects.filter(
        Q(title__icontains=query) |
        Q(description__icontains=query) |
        Q(tags__icontains=query),
        is_active=True
    )
    
    if category and category != 'general':
        rooms = rooms.filter(category=category)
    
    serializer = RoomSerializer(rooms, many=True)
    
    return Response({
        'rooms': serializer.data,
        'count': rooms.count()
    })
```

### Step 2: Run Migration

```bash
cd /Users/audi/Desktop/333/Server
python manage.py migrate community
```

---

## 📊 Testing

After completing manual steps, test with:

```bash
# 1. Get trending rooms
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8000/api/community/rooms/trending/?limit=5"

# 2. Get scheduled rooms
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8000/api/community/rooms/scheduled/"

# 3. Search rooms
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8000/api/community/rooms/search/?q=anxiety"
```

---

## 📝 Next: Frontend Implementation

After backend is complete, implement Flutter UI:
1. Update `CommunityRepository` with new methods
2. Add Trending/Scheduled tabs to `RoomListScreen`
3. Add search bar
4. Update create room form with description & tags
5. Update room cards to show new fields
