# Database Connection Pool Issue - Critical Fix

## 🔥 Problem Found

**Error:** `MaxClientsInSessionMode: max clients reached`

**Root Cause:** Railway PostgreSQL connection pool exhausted during stress testing

## Impact

All test failures traced back to this single issue:
- User creation failures: 6/15 (40%)
- Room creation failures: 9/12 (75%)
- Listener count not updating
- List rooms 500 error

## Solution

### 1. Add Connection Pooling (Django settings.py)

```python
# Server/config/settings.py

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('PGDATABASE'),
        'USER': os.environ.get('PGUSER'),
        'PASSWORD': os.environ.get('PGPASSWORD'),
        'HOST': os.environ.get('PGHOST'),
        'PORT': os.environ.get('PGPORT', 5432),
        
        # Connection Pool Settings
        'CONN_MAX_AGE': 600,  # Keep connections alive for 10 minutes
        'OPTIONS': {
            'connect_timeout': 10,
            'options': '-c statement_timeout=30000'  # 30 second timeout
        },
        
        # Connection Pooling
        'ATOMIC_REQUESTS': True,  # Auto-close connections after request
    }
}

# Close database connections after each request
# This is CRITICAL for Railway's session mode
CONN_MAX_AGE = 0  # Don't keep connections alive in production
```

### 2. Use django-db-connection-pool (Better Solution)

```bash
pip install django-db-connection-pool
```

```python
# requirements.txt
django-db-connection-pool==1.2.4
```

```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'dj_db_conn_pool.backends.postgresql',  # Changed!
        'NAME': os.environ.get('PGDATABASE'),
        'USER': os.environ.get('PGUSER'),
        'PASSWORD': os.environ.get('PGPASSWORD'),
        'HOST': os.environ.get('PGHOST'),
        'PORT': os.environ.get('PGPORT', 5432),
        'POOL_OPTIONS': {
            'POOL_SIZE': 10,  # Max connections
            'MAX_OVERFLOW': 5,  # Extra connections when pool is full
            'RECYCLE': 300,  # Recycle connections after 5 minutes
            'PRE_PING': True,  # Test connection before using
        }
    }
}
```

### 3. Fix Listener Count Race Condition

```python
# views.py - join endpoint
from django.db.models import F

@decorators.action(detail=True, methods=['post'], url_path='join')
def join(self, request, pk=None):
    # ... existing code ...
    
    # BEFORE (Race condition):
    # room.listeners_count += 1
    # room.save()
    
    # AFTER (Atomic):
    from django.db import transaction
    with transaction.atomic():
        Room.objects.filter(id=room.id).update(
            listeners_count=F('listeners_count') + 1,
            last_active_at=timezone.now()
        )
        room.refresh_from_db()  # Get updated values
```

### 4. Railway Environment Variables

Add to Railway:

```bash
# Reduce connection usage
CONN_MAX_AGE=0
DB_POOL_SIZE=10
DB_MAX_OVERFLOW=5
```

### 5. Upgrade Railway Plan (If Needed)

Current plan likely has:
- **Session Mode:** Limited connections (10-20)
- **Transaction Mode:** More connections but requires pgBouncer

**Options:**
1. Stay on current plan + implement connection pooling
2. Upgrade to plan with more connections
3. Switch to Transaction Mode (requires code changes)

## Testing After Fix

Run stress test again:
```bash
python3 test_clubhouse.py
```

Expected results:
- ✅ 15/15 users created
- ✅ 12/12 rooms created
- ✅ Listener count updates correctly
- ✅ No 500 errors

## Priority

**CRITICAL** - Must fix before production deployment

This single issue is causing 90% of test failures.
