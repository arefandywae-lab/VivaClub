#!/bin/bash

# Viva Club API Testing Script
# This script tests all backend endpoints and logs results

# Configuration
BASE_URL="https://vivaclub-production.up.railway.app"
LOG_DIR="./test_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/api_test_$TIMESTAMP.log"
SUMMARY_FILE="$LOG_DIR/summary_$TIMESTAMP.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Create log directory
mkdir -p "$LOG_DIR"

# Initialize log file
echo "==================================================" | tee "$LOG_FILE"
echo "Viva Club API Testing - $(date)" | tee -a "$LOG_FILE"
echo "Base URL: $BASE_URL" | tee -a "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to log messages
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to log section headers
log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "==================================================" | tee -a "$LOG_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
    echo "==================================================" | tee -a "$LOG_FILE"
}

# Function to test an endpoint
test_endpoint() {
    local name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    local auth_header="$5"
    local expected_status="${6:-200}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${YELLOW}Testing: $name${NC}" | tee -a "$LOG_FILE"
    echo "Method: $method" | tee -a "$LOG_FILE"
    echo "Endpoint: $endpoint" | tee -a "$LOG_FILE"
    
    # Build curl command
    local curl_cmd="curl -s -w '\\nHTTP_STATUS:%{http_code}' -X $method '$BASE_URL$endpoint'"
    
    if [ -n "$auth_header" ]; then
        curl_cmd="$curl_cmd -H 'Authorization: Bearer $auth_header'"
    fi
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json' -d '$data'"
    fi
    
    # Execute request
    echo "Executing request..." | tee -a "$LOG_FILE"
    response=$(eval "$curl_cmd")
    
    # Extract status code (after HTTP_STATUS: marker)
    status_code=$(echo "$response" | grep "HTTP_STATUS:" | sed 's/HTTP_STATUS://')
    body=$(echo "$response" | sed '/HTTP_STATUS:/d')
    
    # Log response
    echo "Status Code: $status_code" | tee -a "$LOG_FILE"
    echo "Response Body:" | tee -a "$LOG_FILE"
    echo "$body" | jq '.' 2>/dev/null | tee -a "$LOG_FILE" || echo "$body" | tee -a "$LOG_FILE"
    
    # Check if test passed
    if [ "$status_code" -eq "$expected_status" ] || [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ]; then
        echo -e "${GREEN}✓ PASSED${NC}" | tee -a "$LOG_FILE"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAILED (Expected: $expected_status, Got: $status_code)${NC}" | tee -a "$LOG_FILE"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    echo "---" | tee -a "$LOG_FILE"
    
    # Return clean body for extraction (no colors, no logging)
    echo "$body"
}

# Function to extract value from JSON response
extract_json() {
    # Strip ANSI color codes first, then parse JSON
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g' | jq -r "$2" 2>/dev/null
}

#=================================================
# START TESTING
#=================================================

log_section "1. AUTHENTICATION TESTS"

# 1.1 Register User 1
log "1.1 Register User 1"
USER1_RESPONSE=$(test_endpoint \
    "Register User 1" \
    "POST" \
    "/api/auth/register/" \
    '{
        "username": "testuser_'$TIMESTAMP'_1",
        "password": "test123456",
        "email": "test1_'$TIMESTAMP'@example.com",
        "role": "patient",
        "first_name": "Test",
        "last_name": "User1"
    }' \
    "" \
    "201")

# 1.2 Register User 2
log "1.2 Register User 2"
USER2_RESPONSE=$(test_endpoint \
    "Register User 2" \
    "POST" \
    "/api/auth/register/" \
    '{
        "username": "testuser_'$TIMESTAMP'_2",
        "password": "test123456",
        "email": "test2_'$TIMESTAMP'@example.com",
        "role": "patient",
        "first_name": "Test",
        "last_name": "User2"
    }' \
    "" \
    "201")

# 1.3 Login User 1
log "1.3 Login User 1"
LOGIN1_RESPONSE=$(test_endpoint \
    "Login User 1" \
    "POST" \
    "/api/auth/login/" \
    '{
        "username": "testuser_'$TIMESTAMP'_1",
        "password": "test123456"
    }')

TOKEN1=$(extract_json "$LOGIN1_RESPONSE" ".access")
log "Token 1: ${TOKEN1:0:20}..."

# 1.4 Login User 2
log "1.4 Login User 2"
LOGIN2_RESPONSE=$(test_endpoint \
    "Login User 2" \
    "POST" \
    "/api/auth/login/" \
    '{
        "username": "testuser_'$TIMESTAMP'_2",
        "password": "test123456"
    }')

TOKEN2=$(extract_json "$LOGIN2_RESPONSE" ".access")
log "Token 2: ${TOKEN2:0:20}..."

# 1.5 Get Current User
log "1.5 Get Current User (User 1)"
test_endpoint \
    "Get Current User" \
    "GET" \
    "/api/auth/me/" \
    "" \
    "$TOKEN1"

#=================================================
log_section "2. GHOST PROFILE TESTS"

# 2.1 Get My Ghost Profile
log "2.1 Get My Ghost Profile (User 1)"
GHOST1_RESPONSE=$(test_endpoint \
    "Get My Ghost Profile" \
    "GET" \
    "/api/community/ghosts/me/" \
    "" \
    "$TOKEN1")

GHOST1_ID=$(extract_json "$GHOST1_RESPONSE" ".id")
log "Ghost 1 ID: $GHOST1_ID"

# 2.2 Get User 2 Ghost Profile
log "2.2 Get My Ghost Profile (User 2)"
GHOST2_RESPONSE=$(test_endpoint \
    "Get My Ghost Profile (User 2)" \
    "GET" \
    "/api/community/ghosts/me/" \
    "" \
    "$TOKEN2")

GHOST2_ID=$(extract_json "$GHOST2_RESPONSE" ".id")
log "Ghost 2 ID: $GHOST2_ID"

# 2.3 Update Ghost Profile
log "2.3 Update Ghost Profile"
test_endpoint \
    "Update Ghost Profile" \
    "PATCH" \
    "/api/community/ghosts/me/" \
    '{
        "display_name": "Test Ghost #999"
    }' \
    "$TOKEN1"

# 2.4 List All Ghosts
log "2.4 List All Ghost Profiles"
test_endpoint \
    "List All Ghosts" \
    "GET" \
    "/api/community/ghosts/" \
    "" \
    "$TOKEN1"

# 2.5 Get Specific Ghost
log "2.5 Get Specific Ghost Profile"
test_endpoint \
    "Get Specific Ghost" \
    "GET" \
    "/api/community/ghosts/$GHOST2_ID/" \
    "" \
    "$TOKEN1"

#=================================================
log_section "3. ROOM TESTS"

# 3.1 Create Room
log "3.1 Create Room (User 1)"
ROOM_RESPONSE=$(test_endpoint \
    "Create Room" \
    "POST" \
    "/api/community/rooms/" \
    '{
        "title": "Test Anxiety Support Room",
        "category": "anxiety",
        "description": "This is a test room for anxiety support",
        "tags": ["test", "anxiety", "support"]
    }' \
    "$TOKEN1" \
    "201")

ROOM_ID=$(extract_json "$ROOM_RESPONSE" ".id")
log "Room ID: $ROOM_ID"

# 3.2 List Active Rooms
log "3.2 List Active Rooms"
test_endpoint \
    "List Active Rooms" \
    "GET" \
    "/api/community/rooms/" \
    "" \
    "$TOKEN1"

# 3.3 Get Room Details
log "3.3 Get Room Details"
test_endpoint \
    "Get Room Details" \
    "GET" \
    "/api/community/rooms/$ROOM_ID/" \
    "" \
    "$TOKEN1"

# 3.4 Join Room (User 2)
log "3.4 Join Room (User 2)"
JOIN_RESPONSE=$(test_endpoint \
    "Join Room" \
    "POST" \
    "/api/community/rooms/$ROOM_ID/join/" \
    "" \
    "$TOKEN2")

LIVEKIT_TOKEN=$(extract_json "$JOIN_RESPONSE" ".token")
log "LiveKit Token: ${LIVEKIT_TOKEN:0:30}..."

# 3.5 Leave Room (User 2)
log "3.5 Leave Room (User 2)"
test_endpoint \
    "Leave Room" \
    "POST" \
    "/api/community/rooms/$ROOM_ID/leave/" \
    "" \
    "$TOKEN2"

#=================================================
log_section "4. FOLLOWING SYSTEM TESTS"

# 4.1 Follow Ghost (User 1 follows User 2)
log "4.1 User 1 Follows User 2"
test_endpoint \
    "Follow Ghost" \
    "POST" \
    "/api/community/ghosts/$GHOST2_ID/follow/" \
    "" \
    "$TOKEN1"

# 4.2 Get Following List
log "4.2 Get Following List (User 1)"
test_endpoint \
    "Get Following List" \
    "GET" \
    "/api/community/following/" \
    "" \
    "$TOKEN1"

# 4.3 Create Room as User 2 (for following feed test)
log "4.3 Create Room as User 2"
ROOM2_RESPONSE=$(test_endpoint \
    "Create Room (User 2)" \
    "POST" \
    "/api/community/rooms/" \
    '{
        "title": "User 2 Test Room",
        "category": "general",
        "description": "Room by followed user",
        "tags": ["test"]
    }' \
    "$TOKEN2" \
    "201")

# 4.4 Get Following Feed (User 1 should see User 2's room)
log "4.4 Get Following Feed (User 1)"
test_endpoint \
    "Get Following Feed" \
    "GET" \
    "/api/community/following/feed/" \
    "" \
    "$TOKEN1"

# 4.5 Unfollow Ghost
log "4.5 User 1 Unfollows User 2"
test_endpoint \
    "Unfollow Ghost" \
    "POST" \
    "/api/community/ghosts/$GHOST2_ID/unfollow/" \
    "" \
    "$TOKEN1"

#=================================================
log_section "5. NOTIFICATION TESTS"

# 5.1 Register FCM Token
log "5.1 Register FCM Token"
test_endpoint \
    "Register FCM Token" \
    "POST" \
    "/api/community/fcm-token/" \
    '{
        "token": "test-fcm-token-'$TIMESTAMP'"
    }' \
    "$TOKEN1"

# 5.2 Get Notifications
log "5.2 Get Notifications"
NOTIF_RESPONSE=$(test_endpoint \
    "Get Notifications" \
    "GET" \
    "/api/community/notifications/" \
    "" \
    "$TOKEN1")

# Extract first notification ID if exists
NOTIF_ID=$(extract_json "$NOTIF_RESPONSE" ".notifications[0].id")

if [ -n "$NOTIF_ID" ] && [ "$NOTIF_ID" != "null" ]; then
    # 5.3 Mark Notification as Read
    log "5.3 Mark Notification as Read"
    test_endpoint \
        "Mark Notification as Read" \
        "POST" \
        "/api/community/notifications/$NOTIF_ID/mark_read/" \
        "" \
        "$TOKEN1"
fi

# 5.4 Mark All as Read
log "5.4 Mark All Notifications as Read"
test_endpoint \
    "Mark All as Read" \
    "POST" \
    "/api/community/notifications/mark_all_read/" \
    "" \
    "$TOKEN1"

#=================================================
log_section "6. ENHANCED DISCOVERY TESTS"

# 6.1 Get Trending Rooms
log "6.1 Get Trending Rooms"
test_endpoint \
    "Get Trending Rooms" \
    "GET" \
    "/api/community/rooms/trending/?limit=10" \
    "" \
    "$TOKEN1"

# 6.2 Get Trending by Category
log "6.2 Get Trending Rooms (Anxiety Category)"
test_endpoint \
    "Get Trending by Category" \
    "GET" \
    "/api/community/rooms/trending/?category=anxiety&limit=5" \
    "" \
    "$TOKEN1"

# 6.3 Get Scheduled Rooms
log "6.3 Get Scheduled Rooms"
test_endpoint \
    "Get Scheduled Rooms" \
    "GET" \
    "/api/community/rooms/scheduled/?upcoming=true" \
    "" \
    "$TOKEN1"

# 6.4 Search Rooms
log "6.4 Search Rooms (query: anxiety)"
test_endpoint \
    "Search Rooms" \
    "GET" \
    "/api/community/rooms/search/?q=anxiety" \
    "" \
    "$TOKEN1"

# 6.5 Search with Category Filter
log "6.5 Search Rooms with Category Filter"
test_endpoint \
    "Search with Category" \
    "GET" \
    "/api/community/rooms/search/?q=test&category=anxiety" \
    "" \
    "$TOKEN1"

#=================================================
log_section "TEST SUMMARY"

# Calculate success rate
SUCCESS_RATE=0
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
fi

# Create summary
{
    echo "==================================================="
    echo "TEST SUMMARY - $(date)"
    echo "==================================================="
    echo ""
    echo "Total Tests:   $TOTAL_TESTS"
    echo "Passed:        $PASSED_TESTS"
    echo "Failed:        $FAILED_TESTS"
    echo "Success Rate:  $SUCCESS_RATE%"
    echo ""
    echo "==================================================="
    echo "Log File: $LOG_FILE"
    echo "==================================================="
} | tee "$SUMMARY_FILE"

# Print summary to console with colors
echo ""
echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
echo -e "Total Tests:   ${YELLOW}$TOTAL_TESTS${NC}"
echo -e "Passed:        ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:        ${RED}$FAILED_TESTS${NC}"
echo -e "Success Rate:  ${YELLOW}$SUCCESS_RATE%${NC}"
echo ""
echo -e "${BLUE}==================================================${NC}"
echo -e "Full Log: ${YELLOW}$LOG_FILE${NC}"
echo -e "Summary:  ${YELLOW}$SUMMARY_FILE${NC}"
echo -e "${BLUE}==================================================${NC}"

# Exit with error code if any tests failed
if [ $FAILED_TESTS -gt 0 ]; then
    exit 1
else
    exit 0
fi
