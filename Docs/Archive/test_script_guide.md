# API Testing Script Usage Guide

## Quick Start

### Run the test script:
```bash
cd /Users/audi/Desktop/333
./test_api.sh
```

## What It Does

The script automatically tests **ALL** backend features:

1. **Authentication** (4 tests)
   - Register 2 users
   - Login both users
   - Get current user profile

2. **Ghost Profiles** (5 tests)
   - Get ghost profiles
   - Update profile
   - List all ghosts
   - Get specific ghost

3. **Rooms** (5 tests)
   - Create room
   - List rooms
   - Get room details
   - Join room
   - Leave room

4. **Following System** (5 tests)
   - Follow ghost
   - Get following list
   - Create room by followed user
   - Get following feed
   - Unfollow ghost

5. **Notifications** (4 tests)
   - Register FCM token
   - Get notifications
   - Mark notification as read
   - Mark all as read

6. **Enhanced Discovery** (5 tests)
   - Get trending rooms
   - Get trending by category
   - Get scheduled rooms
   - Search rooms
   - Search with category filter

**Total: ~28 API endpoint tests**

## Output

### Console Output
- Color-coded results (Green = Pass, Red = Fail)
- Real-time progress
- Summary at the end

### Log Files
Located in `./test_logs/`:

1. **Full Log:** `api_test_YYYYMMDD_HHMMSS.log`
   - Complete request/response details
   - All JSON responses
   - Error messages

2. **Summary:** `summary_YYYYMMDD_HHMMSS.txt`
   - Total tests run
   - Pass/fail counts
   - Success rate percentage

## Example Output

```
==================================================
1. AUTHENTICATION TESTS
==================================================
Testing: Register User 1
Method: POST
Endpoint: /api/auth/register/
Executing request...
Status Code: 201
Response Body:
{
  "id": 1,
  "username": "testuser_20260215_162800_1",
  "email": "test1_20260215_162800@example.com",
  "role": "patient"
}
✓ PASSED
---

==================================================
TEST SUMMARY
==================================================

Total Tests:   28
Passed:        26
Failed:        2
Success Rate:  92.86%

==================================================
Full Log: ./test_logs/api_test_20260215_162800.log
Summary:  ./test_logs/summary_20260215_162800.txt
==================================================
```

## Troubleshooting

### If tests fail:

1. **Check the detailed log:**
   ```bash
   cat ./test_logs/api_test_*.log
   ```

2. **Common issues:**
   - **401 Unauthorized:** Token expired or auth issue
   - **404 Not Found:** Endpoint doesn't exist
   - **500 Internal Server Error:** Backend error (check Railway logs)

3. **View latest log:**
   ```bash
   ls -lt ./test_logs/
   cat ./test_logs/api_test_*.log | tail -100
   ```

## Requirements

- `curl` - HTTP client
- `jq` - JSON parser
- `bc` - Calculator for success rate

### Install requirements (if missing):
```bash
# macOS
brew install jq bc

# Ubuntu/Debian
sudo apt-get install jq bc
```

## Advanced Usage

### Test specific Railway deployment:
Edit `test_api.sh` and change:
```bash
BASE_URL="https://your-custom-url.railway.app"
```

### Run in verbose mode:
```bash
bash -x ./test_api.sh
```

### Save output to custom location:
```bash
LOG_DIR="./my_logs" ./test_api.sh
```

## CI/CD Integration

Exit codes:
- `0` - All tests passed
- `1` - One or more tests failed

Use in CI/CD:
```bash
./test_api.sh && echo "Deploy!" || echo "Fix errors first!"
```

## Notes

- Each test run creates unique users (timestamped)
- Tests are independent and can run multiple times
- Logs are never overwritten (timestamped filenames)
- Script tests against Railway production URL by default
