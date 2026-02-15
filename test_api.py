#!/usr/bin/env python3
"""
Viva Club API Testing Script
Tests all backend endpoints and generates detailed logs
"""

import requests
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, Tuple

# Configuration
BASE_URL = "https://vivaclub-production.up.railway.app"
LOG_DIR = Path("./test_logs")
TIMESTAMP = datetime.now().strftime("%Y%m%d_%H%M%S")
LOG_FILE = LOG_DIR / f"api_test_{TIMESTAMP}.log"
SUMMARY_FILE = LOG_DIR / f"summary_{TIMESTAMP}.txt"

# Colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

# Test counters
total_tests = 0
passed_tests = 0
failed_tests = 0

# Create log directory
LOG_DIR.mkdir(exist_ok=True)

# Initialize log file
def log(message: str, to_file_only: bool = False):
    """Log message to file and optionally to console"""
    with open(LOG_FILE, 'a') as f:
        # Strip ANSI codes for file
        clean_message = message
        for color in [Colors.RED, Colors.GREEN, Colors.YELLOW, Colors.BLUE, Colors.NC]:
            clean_message = clean_message.replace(color, '')
        f.write(clean_message + '\n')
    
    if not to_file_only:
        print(message)

def log_section(title: str):
    """Log a section header"""
    log("")
    log("=" * 50)
    log(f"{Colors.BLUE}{title}{Colors.NC}")
    log("=" * 50)

def test_endpoint(
    name: str,
    method: str,
    endpoint: str,
    data: Optional[Dict] = None,
    token: Optional[str] = None,
    expected_status: int = 200
) -> Tuple[bool, Optional[Dict]]:
    """
    Test an API endpoint
    Returns: (success: bool, response_data: dict or None)
    """
    global total_tests, passed_tests, failed_tests
    
    total_tests += 1
    
    log(f"{Colors.YELLOW}Testing: {name}{Colors.NC}")
    log(f"Method: {method}")
    log(f"Endpoint: {endpoint}")
    
    # Build headers
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    
    # Build URL
    url = f"{BASE_URL}{endpoint}"
    
    try:
        log("Executing request...")
        
        # Make request
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=10)
        elif method == "POST":
            response = requests.post(url, headers=headers, json=data, timeout=10)
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data, timeout=10)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers, timeout=10)
        else:
            raise ValueError(f"Unsupported method: {method}")
        
        # Log response
        log(f"Status Code: {response.status_code}")
        log("Response Body:")
        
        try:
            response_data = response.json()
            log(json.dumps(response_data, indent=2))
        except:
            response_data = None
            log(response.text)
        
        # Check if passed
        if response.status_code == expected_status or response.status_code in [200, 201]:
            log(f"{Colors.GREEN}✓ PASSED{Colors.NC}")
            passed_tests += 1
            log("---")
            return True, response_data
        else:
            log(f"{Colors.RED}✗ FAILED (Expected: {expected_status}, Got: {response.status_code}){Colors.NC}")
            failed_tests += 1
            log("---")
            return False, response_data
            
    except Exception as e:
        log(f"{Colors.RED}✗ ERROR: {str(e)}{Colors.NC}")
        failed_tests += 1
        log("---")
        return False, None

def main():
    """Main test execution"""
    
    # Initialize log
    log("=" * 50)
    log(f"Viva Club API Testing - {datetime.now()}")
    log(f"Base URL: {BASE_URL}")
    log("=" * 50)
    log("")
    
    # Variables to store tokens and IDs
    token1 = None
    token2 = None
    ghost1_id = None
    ghost2_id = None
    room_id = None
    
    #=================================================
    # 1. AUTHENTICATION TESTS
    #=================================================
    log_section("1. AUTHENTICATION TESTS")
    
    # 1.1 Register User 1
    log("1.1 Register User 1")
    success, response = test_endpoint(
        "Register User 1",
        "POST",
        "/api/auth/register/",
        data={
            "username": f"testuser_{TIMESTAMP}_1",
            "password": "test123456",
            "email": f"test1_{TIMESTAMP}@example.com",
            "role": "patient",
            "first_name": "Test",
            "last_name": "User1"
        },
        expected_status=201
    )
    
    # 1.2 Register User 2
    log("1.2 Register User 2")
    success, response = test_endpoint(
        "Register User 2",
        "POST",
        "/api/auth/register/",
        data={
            "username": f"testuser_{TIMESTAMP}_2",
            "password": "test123456",
            "email": f"test2_{TIMESTAMP}@example.com",
            "role": "patient",
            "first_name": "Test",
            "last_name": "User2"
        },
        expected_status=201
    )
    
    # 1.3 Login User 1
    log("1.3 Login User 1")
    success, response = test_endpoint(
        "Login User 1",
        "POST",
        "/api/auth/login/",
        data={
            "username": f"testuser_{TIMESTAMP}_1",
            "password": "test123456"
        }
    )
    if success and response:
        token1 = response.get("access")
        log(f"Token 1: {token1[:20]}..." if token1 else "Token 1: NOT FOUND")
    
    # 1.4 Login User 2
    log("1.4 Login User 2")
    success, response = test_endpoint(
        "Login User 2",
        "POST",
        "/api/auth/login/",
        data={
            "username": f"testuser_{TIMESTAMP}_2",
            "password": "test123456"
        }
    )
    if success and response:
        token2 = response.get("access")
        log(f"Token 2: {token2[:20]}..." if token2 else "Token 2: NOT FOUND")
    
    # 1.5 Get Current User
    log("1.5 Get Current User (User 1)")
    test_endpoint(
        "Get Current User",
        "GET",
        "/api/auth/me/",
        token=token1
    )
    
    #=================================================
    # 2. GHOST PROFILE TESTS
    #=================================================
    log_section("2. GHOST PROFILE TESTS")
    
    # 2.1 Get My Ghost Profile (User 1)
    log("2.1 Get My Ghost Profile (User 1)")
    success, response = test_endpoint(
        "Get My Ghost Profile",
        "GET",
        "/api/community/ghosts/me/",
        token=token1
    )
    if success and response:
        ghost1_id = response.get("id")
        log(f"Ghost 1 ID: {ghost1_id}")
    
    # 2.2 Get My Ghost Profile (User 2)
    log("2.2 Get My Ghost Profile (User 2)")
    success, response = test_endpoint(
        "Get My Ghost Profile (User 2)",
        "GET",
        "/api/community/ghosts/me/",
        token=token2
    )
    if success and response:
        ghost2_id = response.get("id")
        log(f"Ghost 2 ID: {ghost2_id}")
    
    # 2.3 Update Ghost Profile
    log("2.3 Update Ghost Profile")
    test_endpoint(
        "Update Ghost Profile",
        "PATCH",
        "/api/community/ghosts/me/",
        data={"display_name": "Test Ghost #999"},
        token=token1
    )
    
    # 2.4 List All Ghosts
    log("2.4 List All Ghost Profiles")
    test_endpoint(
        "List All Ghosts",
        "GET",
        "/api/community/ghosts/",
        token=token1
    )
    
    # 2.5 Get Specific Ghost
    if ghost2_id:
        log("2.5 Get Specific Ghost Profile")
        test_endpoint(
            "Get Specific Ghost",
            "GET",
            f"/api/community/ghosts/{ghost2_id}/",
            token=token1
        )
    
    #=================================================
    # 3. ROOM TESTS
    #=================================================
    log_section("3. ROOM TESTS")
    
    # 3.1 Create Room
    log("3.1 Create Room (User 1)")
    success, response = test_endpoint(
        "Create Room",
        "POST",
        "/api/community/rooms/",
        data={
            "title": "Test Anxiety Support Room",
            "category": "anxiety",
            "description": "This is a test room for anxiety support",
            "tags": ["test", "anxiety", "support"]
        },
        token=token1,
        expected_status=201
    )
    if success and response:
        room_id = response.get("id")
        log(f"Room ID: {room_id}")
    
    # 3.2 List Active Rooms
    log("3.2 List Active Rooms")
    test_endpoint(
        "List Active Rooms",
        "GET",
        "/api/community/rooms/",
        token=token1
    )
    
    # 3.3 Get Room Details
    if room_id:
        log("3.3 Get Room Details")
        test_endpoint(
            "Get Room Details",
            "GET",
            f"/api/community/rooms/{room_id}/",
            token=token1
        )
    
    # 3.4 Join Room (User 2)
    if room_id:
        log("3.4 Join Room (User 2)")
        success, response = test_endpoint(
            "Join Room",
            "POST",
            f"/api/community/rooms/{room_id}/join/",
            token=token2
        )
        if success and response:
            livekit_token = response.get("token")
            log(f"LiveKit Token: {livekit_token[:30]}..." if livekit_token else "LiveKit Token: NOT FOUND")
    
    # 3.5 Leave Room (User 2)
    if room_id:
        log("3.5 Leave Room (User 2)")
        test_endpoint(
            "Leave Room",
            "POST",
            f"/api/community/rooms/{room_id}/leave/",
            token=token2
        )
    
    #=================================================
    # 4. FOLLOWING SYSTEM TESTS
    #=================================================
    log_section("4. FOLLOWING SYSTEM TESTS")
    
    # 4.1 Follow Ghost
    if ghost2_id:
        log("4.1 User 1 Follows User 2")
        test_endpoint(
            "Follow Ghost",
            "POST",
            f"/api/community/ghosts/{ghost2_id}/follow/",
            token=token1
        )
    
    # 4.2 Get Following List
    log("4.2 Get Following List (User 1)")
    test_endpoint(
        "Get Following List",
        "GET",
        "/api/community/following/",
        token=token1
    )
    
    # 4.3 Create Room as User 2
    log("4.3 Create Room as User 2")
    test_endpoint(
        "Create Room (User 2)",
        "POST",
        "/api/community/rooms/",
        data={
            "title": "User 2 Test Room",
            "category": "general",
            "description": "Room by followed user",
            "tags": ["test"]
        },
        token=token2,
        expected_status=201
    )
    
    # 4.4 Get Following Feed
    log("4.4 Get Following Feed (User 1)")
    test_endpoint(
        "Get Following Feed",
        "GET",
        "/api/community/following/feed/",
        token=token1
    )
    
    # 4.5 Unfollow Ghost
    if ghost2_id:
        log("4.5 User 1 Unfollows User 2")
        test_endpoint(
            "Unfollow Ghost",
            "POST",
            f"/api/community/ghosts/{ghost2_id}/unfollow/",
            token=token1
        )
    
    #=================================================
    # 5. NOTIFICATION TESTS
    #=================================================
    log_section("5. NOTIFICATION TESTS")
    
    # 5.1 Register FCM Token
    log("5.1 Register FCM Token")
    test_endpoint(
        "Register FCM Token",
        "POST",
        "/api/community/fcm-token/",
        data={"token": f"test-fcm-token-{TIMESTAMP}"},
        token=token1
    )
    
    # 5.2 Get Notifications
    log("5.2 Get Notifications")
    success, response = test_endpoint(
        "Get Notifications",
        "GET",
        "/api/community/notifications/",
        token=token1
    )
    
    # 5.3 Mark Notification as Read (if exists)
    if success and response and response.get("notifications"):
        notif_id = response["notifications"][0].get("id")
        if notif_id:
            log("5.3 Mark Notification as Read")
            test_endpoint(
                "Mark Notification as Read",
                "POST",
                f"/api/community/notifications/{notif_id}/mark_read/",
                token=token1
            )
    
    # 5.4 Mark All as Read
    log("5.4 Mark All Notifications as Read")
    test_endpoint(
        "Mark All as Read",
        "POST",
        "/api/community/notifications/mark_all_read/",
        token=token1
    )
    
    #=================================================
    # 6. ENHANCED DISCOVERY TESTS
    #=================================================
    log_section("6. ENHANCED DISCOVERY TESTS")
    
    # 6.1 Get Trending Rooms
    log("6.1 Get Trending Rooms")
    test_endpoint(
        "Get Trending Rooms",
        "GET",
        "/api/community/rooms/trending/?limit=10",
        token=token1
    )
    
    # 6.2 Get Trending by Category
    log("6.2 Get Trending Rooms (Anxiety Category)")
    test_endpoint(
        "Get Trending by Category",
        "GET",
        "/api/community/rooms/trending/?category=anxiety&limit=5",
        token=token1
    )
    
    # 6.3 Get Scheduled Rooms
    log("6.3 Get Scheduled Rooms")
    test_endpoint(
        "Get Scheduled Rooms",
        "GET",
        "/api/community/rooms/scheduled/?upcoming=true",
        token=token1
    )
    
    # 6.4 Search Rooms
    log("6.4 Search Rooms (query: anxiety)")
    test_endpoint(
        "Search Rooms",
        "GET",
        "/api/community/rooms/search/?q=anxiety",
        token=token1
    )
    
    # 6.5 Search with Category Filter
    log("6.5 Search Rooms with Category Filter")
    test_endpoint(
        "Search with Category",
        "GET",
        "/api/community/rooms/search/?q=test&category=anxiety",
        token=token1
    )
    
    #=================================================
    # TEST SUMMARY
    #=================================================
    log_section("TEST SUMMARY")
    
    success_rate = (passed_tests * 100 / total_tests) if total_tests > 0 else 0
    
    summary = f"""===================================================
TEST SUMMARY - {datetime.now()}
===================================================

Total Tests:   {total_tests}
Passed:        {passed_tests}
Failed:        {failed_tests}
Success Rate:  {success_rate:.2f}%

===================================================
Log File: {LOG_FILE}
===================================================
"""
    
    # Write summary to file
    with open(SUMMARY_FILE, 'w') as f:
        f.write(summary)
    
    # Print colored summary to console
    print()
    print(f"{Colors.BLUE}{'=' * 50}{Colors.NC}")
    print(f"{Colors.BLUE}TEST SUMMARY{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 50}{Colors.NC}")
    print()
    print(f"Total Tests:   {Colors.YELLOW}{total_tests}{Colors.NC}")
    print(f"Passed:        {Colors.GREEN}{passed_tests}{Colors.NC}")
    print(f"Failed:        {Colors.RED}{failed_tests}{Colors.NC}")
    print(f"Success Rate:  {Colors.YELLOW}{success_rate:.2f}%{Colors.NC}")
    print()
    print(f"{Colors.BLUE}{'=' * 50}{Colors.NC}")
    print(f"Full Log: {Colors.YELLOW}{LOG_FILE}{Colors.NC}")
    print(f"Summary:  {Colors.YELLOW}{SUMMARY_FILE}{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 50}{Colors.NC}")
    
    # Exit with appropriate code
    sys.exit(0 if failed_tests == 0 else 1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Test interrupted by user{Colors.NC}")
        sys.exit(1)
    except Exception as e:
        print(f"\n{Colors.RED}Fatal error: {e}{Colors.NC}")
        sys.exit(1)
