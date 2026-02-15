#!/usr/bin/env python3
"""
Viva Club Clubhouse Features & Stress Test
Tests room interactions, invites, and creates multiple rooms/users for stress testing
"""

import requests
import json
import sys
import time
import concurrent.futures
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, List, Tuple

# Configuration
BASE_URL = "https://vivaclub-production.up.railway.app"
LOG_DIR = Path("./test_logs")
TIMESTAMP = datetime.now().strftime("%Y%m%d_%H%M%S")
LOG_FILE = LOG_DIR / f"clubhouse_test_{TIMESTAMP}.log"
SUMMARY_FILE = LOG_DIR / f"clubhouse_summary_{TIMESTAMP}.txt"

# Test Configuration
NUM_USERS = 15  # Create 15 test users
NUM_ROOMS = 12  # Create 12 test rooms
CATEGORIES = ["anxiety", "depression", "general", "addiction"]

# Colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'

# Test counters
total_tests = 0
passed_tests = 0
failed_tests = 0

# Storage for created entities
users = []  # List of {username, token, ghost_id}
rooms = []  # List of {room_id, title, host_token, host_ghost_id}

# Create log directory
LOG_DIR.mkdir(exist_ok=True)

def log(message: str, color: str = ""):
    """Log message to file and console"""
    with open(LOG_FILE, 'a') as f:
        # Strip ANSI codes for file
        clean_message = message
        for c in [Colors.RED, Colors.GREEN, Colors.YELLOW, Colors.BLUE, Colors.MAGENTA, Colors.CYAN, Colors.NC]:
            clean_message = clean_message.replace(c, '')
        f.write(clean_message + '\n')
    
    if color:
        print(f"{color}{message}{Colors.NC}")
    else:
        print(message)

def log_section(title: str):
    """Log a section header"""
    log("")
    log("=" * 60)
    log(title, Colors.BLUE)
    log("=" * 60)

def test_endpoint(
    name: str,
    method: str,
    endpoint: str,
    data: Optional[Dict] = None,
    token: Optional[str] = None,
    expected_status: int = 200,
    silent: bool = False
) -> Tuple[bool, Optional[Dict]]:
    """Test an API endpoint"""
    global total_tests, passed_tests, failed_tests
    
    total_tests += 1
    
    if not silent:
        log(f"Testing: {name}", Colors.YELLOW)
    
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    
    url = f"{BASE_URL}{endpoint}"
    
    try:
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
        
        try:
            response_data = response.json()
        except:
            response_data = None
        
        if response.status_code == expected_status or response.status_code in [200, 201]:
            if not silent:
                log(f"✓ PASSED - {response.status_code}", Colors.GREEN)
            passed_tests += 1
            return True, response_data
        else:
            if not silent:
                log(f"✗ FAILED - Expected: {expected_status}, Got: {response.status_code}", Colors.RED)
                if response_data:
                    log(f"  Response: {json.dumps(response_data, indent=2)}")
            failed_tests += 1
            return False, response_data
            
    except Exception as e:
        if not silent:
            log(f"✗ ERROR: {str(e)}", Colors.RED)
        failed_tests += 1
        return False, None

def create_user(index: int) -> Optional[Dict]:
    """Create a single user and return their info"""
    username = f"clubhouse_user_{TIMESTAMP}_{index}"
    
    # Register
    success, response = test_endpoint(
        f"Register User {index}",
        "POST",
        "/api/auth/register/",
        data={
            "username": username,
            "password": "test123456",
            "email": f"clubhouse{index}_{TIMESTAMP}@example.com",
            "role": "patient",
            "first_name": f"User",
            "last_name": f"{index}"
        },
        expected_status=201,
        silent=True
    )
    
    if not success:
        return None
    
    # Login
    success, response = test_endpoint(
        f"Login User {index}",
        "POST",
        "/api/auth/login/",
        data={
            "username": username,
            "password": "test123456"
        },
        silent=True
    )
    
    if not success or not response:
        return None
    
    token = response.get("access")
    
    # Get ghost profile
    success, ghost_response = test_endpoint(
        f"Get Ghost Profile {index}",
        "GET",
        "/api/community/ghosts/me/",
        token=token,
        silent=True
    )
    
    if not success or not ghost_response:
        return None
    
    ghost_id = ghost_response.get("id")
    ghost_name = ghost_response.get("display_name")
    
    return {
        "index": index,
        "username": username,
        "token": token,
        "ghost_id": ghost_id,
        "ghost_name": ghost_name
    }

def create_room(user: Dict, room_index: int, category: str) -> Optional[Dict]:
    """Create a room for a user"""
    success, response = test_endpoint(
        f"Create Room {room_index}",
        "POST",
        "/api/community/rooms/",
        data={
            "title": f"Test Room #{room_index} - {category.title()}",
            "category": category,
            "description": f"Stress test room {room_index} for {category}",
            "tags": ["test", "stress", category]
        },
        token=user["token"],
        expected_status=201,
        silent=True
    )
    
    if not success or not response:
        return None
    
    return {
        "room_id": response.get("id"),
        "title": response.get("title"),
        "host_token": user["token"],
        "host_ghost_id": user["ghost_id"],
        "host_name": user["ghost_name"],
        "category": category
    }

def main():
    """Main test execution"""
    
    log("=" * 60)
    log(f"Viva Club Clubhouse Features & Stress Test", Colors.CYAN)
    log(f"Started: {datetime.now()}")
    log(f"Base URL: {BASE_URL}")
    log("=" * 60)
    log("")
    
    #=================================================
    # PHASE 1: CREATE USERS
    #=================================================
    log_section(f"PHASE 1: Creating {NUM_USERS} Test Users")
    
    log(f"Creating {NUM_USERS} users in parallel...", Colors.CYAN)
    start_time = time.time()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        future_to_index = {executor.submit(create_user, i): i for i in range(1, NUM_USERS + 1)}
        
        for future in concurrent.futures.as_completed(future_to_index):
            index = future_to_index[future]
            try:
                user = future.result()
                if user:
                    users.append(user)
                    log(f"✓ User {index} created: {user['ghost_name']}", Colors.GREEN)
                else:
                    log(f"✗ User {index} failed", Colors.RED)
            except Exception as e:
                log(f"✗ User {index} error: {e}", Colors.RED)
    
    elapsed = time.time() - start_time
    log(f"\nCreated {len(users)}/{NUM_USERS} users in {elapsed:.2f}s", Colors.CYAN)
    
    if len(users) < 3:
        log("Not enough users created. Aborting.", Colors.RED)
        sys.exit(1)
    
    #=================================================
    # PHASE 2: CREATE ROOMS
    #=================================================
    log_section(f"PHASE 2: Creating {NUM_ROOMS} Test Rooms")
    
    log(f"Creating {NUM_ROOMS} rooms...", Colors.CYAN)
    start_time = time.time()
    
    for i in range(NUM_ROOMS):
        user = users[i % len(users)]  # Distribute rooms among users
        category = CATEGORIES[i % len(CATEGORIES)]
        
        room = create_room(user, i + 1, category)
        if room:
            rooms.append(room)
            log(f"✓ Room {i+1} created by {user['ghost_name']}: {room['title']}", Colors.GREEN)
        else:
            log(f"✗ Room {i+1} failed", Colors.RED)
    
    elapsed = time.time() - start_time
    log(f"\nCreated {len(rooms)}/{NUM_ROOMS} rooms in {elapsed:.2f}s", Colors.CYAN)
    
    #=================================================
    # PHASE 3: ROOM INTERACTION TESTS
    #=================================================
    log_section("PHASE 3: Room Interaction Tests")
    
    if len(rooms) > 0 and len(users) > 1:
        test_room = rooms[0]
        host = users[0]
        listener = users[1]
        
        # Test 1: Join Room
        log("\n3.1 Test: Join Room", Colors.YELLOW)
        success, join_response = test_endpoint(
            "User joins room",
            "POST",
            f"/api/community/rooms/{test_room['room_id']}/join/",
            token=listener["token"]
        )
        
        if success and join_response:
            livekit_token = join_response.get("token")
            is_host = join_response.get("is_host")
            identity = join_response.get("identity")
            
            log(f"  LiveKit Token: {livekit_token[:30]}...", Colors.CYAN)
            log(f"  Is Host: {is_host}", Colors.CYAN)
            log(f"  Identity: {identity}", Colors.CYAN)
            
            # Test 2: Invite to Speak
            log("\n3.2 Test: Invite to Speak", Colors.YELLOW)
            success, invite_response = test_endpoint(
                "Host invites listener to speak",
                "POST",
                f"/api/community/rooms/{test_room['room_id']}/invite/",
                data={"identity": identity},
                token=host["token"]
            )
            
            if success:
                log("  ✓ Invite successful!", Colors.GREEN)
            
            # Test 3: Leave Room
            log("\n3.3 Test: Leave Room", Colors.YELLOW)
            test_endpoint(
                "User leaves room",
                "POST",
                f"/api/community/rooms/{test_room['room_id']}/leave/",
                token=listener["token"]
            )
    
    #=================================================
    # PHASE 4: FOLLOWING & NOTIFICATIONS
    #=================================================
    log_section("PHASE 4: Following & Notification Tests")
    
    if len(users) >= 3:
        user1 = users[0]
        user2 = users[1]
        user3 = users[2]
        
        # Test 1: Follow Multiple Users
        log("\n4.1 Test: User 1 follows User 2 and User 3", Colors.YELLOW)
        test_endpoint(
            "Follow User 2",
            "POST",
            f"/api/community/ghosts/{user2['ghost_id']}/follow/",
            token=user1["token"]
        )
        
        test_endpoint(
            "Follow User 3",
            "POST",
            f"/api/community/ghosts/{user3['ghost_id']}/follow/",
            token=user1["token"]
        )
        
        # Test 2: Get Following List
        log("\n4.2 Test: Get Following List", Colors.YELLOW)
        success, following = test_endpoint(
            "Get following list",
            "GET",
            "/api/community/following/",
            token=user1["token"]
        )
        
        if success and following:
            log(f"  Following {len(following)} users", Colors.CYAN)
        
        # Test 3: Get Following Feed
        log("\n4.3 Test: Get Following Feed", Colors.YELLOW)
        success, feed = test_endpoint(
            "Get following feed",
            "GET",
            "/api/community/following/feed/",
            token=user1["token"]
        )
        
        if success and feed:
            rooms_in_feed = feed.get("rooms", [])
            log(f"  Found {len(rooms_in_feed)} rooms in feed", Colors.CYAN)
        
        # Test 4: Register FCM Token
        log("\n4.4 Test: Register FCM Token", Colors.YELLOW)
        test_endpoint(
            "Register FCM token",
            "POST",
            "/api/community/fcm-token/",
            data={"token": f"fcm-test-{TIMESTAMP}"},
            token=user1["token"]
        )
        
        # Test 5: Get Notifications
        log("\n4.5 Test: Get Notifications", Colors.YELLOW)
        success, notifs = test_endpoint(
            "Get notifications",
            "GET",
            "/api/community/notifications/",
            token=user1["token"]
        )
        
        if success and notifs:
            notifications = notifs.get("notifications", [])
            unread_count = notifs.get("unread_count", 0)
            log(f"  Total notifications: {len(notifications)}", Colors.CYAN)
            log(f"  Unread count: {unread_count}", Colors.CYAN)
            
            if notifications:
                log(f"  Latest notification type: {notifications[0].get('type')}", Colors.CYAN)
    
    #=================================================
    # PHASE 5: DISCOVERY TESTS
    #=================================================
    log_section("PHASE 5: Enhanced Discovery Tests")
    
    if len(users) > 0:
        test_user = users[0]
        
        # Test 1: Get Trending Rooms
        log("\n5.1 Test: Get Trending Rooms", Colors.YELLOW)
        success, trending = test_endpoint(
            "Get trending rooms",
            "GET",
            "/api/community/rooms/trending/?limit=20",
            token=test_user["token"]
        )
        
        if success and trending:
            trending_rooms = trending.get("rooms", [])
            log(f"  Found {len(trending_rooms)} trending rooms", Colors.CYAN)
            
            if trending_rooms:
                top_room = trending_rooms[0]
                log(f"  Top room: {top_room.get('title')}", Colors.CYAN)
                log(f"  Trending score: {top_room.get('trending_score'):.2f}", Colors.CYAN)
        
        # Test 2: Search Rooms
        log("\n5.2 Test: Search Rooms", Colors.YELLOW)
        success, search = test_endpoint(
            "Search for 'test' rooms",
            "GET",
            "/api/community/rooms/search/?q=test",
            token=test_user["token"]
        )
        
        if success and search:
            search_results = search.get("rooms", [])
            log(f"  Found {len(search_results)} rooms matching 'test'", Colors.CYAN)
        
        # Test 3: Search by Category
        log("\n5.3 Test: Search by Category", Colors.YELLOW)
        success, category_search = test_endpoint(
            "Search anxiety category",
            "GET",
            "/api/community/rooms/search/?category=anxiety",
            token=test_user["token"]
        )
        
        if success and category_search:
            category_rooms = category_search.get("rooms", [])
            log(f"  Found {len(category_rooms)} anxiety rooms", Colors.CYAN)
    
    #=================================================
    # PHASE 6: STRESS TEST - CONCURRENT JOINS
    #=================================================
    log_section("PHASE 6: Stress Test - Concurrent Room Joins")
    
    if len(rooms) > 0 and len(users) >= 5:
        test_room = rooms[0]
        
        log(f"Testing {min(10, len(users))} users joining room simultaneously...", Colors.CYAN)
        start_time = time.time()
        
        join_results = []
        
        def join_room(user):
            success, response = test_endpoint(
                f"User {user['index']} joins",
                "POST",
                f"/api/community/rooms/{test_room['room_id']}/join/",
                token=user["token"],
                silent=True
            )
            return (user['index'], success)
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(join_room, users[i]) for i in range(min(10, len(users)))]
            
            for future in concurrent.futures.as_completed(futures):
                try:
                    user_index, success = future.result()
                    join_results.append(success)
                    if success:
                        log(f"  ✓ User {user_index} joined", Colors.GREEN)
                    else:
                        log(f"  ✗ User {user_index} failed", Colors.RED)
                except Exception as e:
                    log(f"  ✗ Error: {e}", Colors.RED)
        
        elapsed = time.time() - start_time
        successful_joins = sum(join_results)
        log(f"\n{successful_joins}/{len(join_results)} users joined successfully in {elapsed:.2f}s", Colors.CYAN)
        
        # Get room details to verify listener count
        log("\nVerifying room listener count...", Colors.CYAN)
        success, room_details = test_endpoint(
            "Get room details",
            "GET",
            f"/api/community/rooms/{test_room['room_id']}/",
            token=users[0]["token"],
            silent=True
        )
        
        if success and room_details:
            listener_count = room_details.get("listeners_count", 0)
            log(f"  Room listener count: {listener_count}", Colors.CYAN)
    
    #=================================================
    # PHASE 7: LIST ALL ACTIVE ROOMS
    #=================================================
    log_section("PHASE 7: List All Active Rooms")
    
    if len(users) > 0:
        success, all_rooms = test_endpoint(
            "Get all active rooms",
            "GET",
            "/api/community/rooms/",
            token=users[0]["token"]
        )
        
        if success and all_rooms:
            log(f"Total active rooms: {len(all_rooms)}", Colors.CYAN)
            
            # Group by category
            by_category = {}
            for room in all_rooms:
                cat = room.get("category", "unknown")
                by_category[cat] = by_category.get(cat, 0) + 1
            
            log("\nRooms by category:", Colors.CYAN)
            for cat, count in by_category.items():
                log(f"  {cat}: {count} rooms", Colors.CYAN)
    
    #=================================================
    # FINAL SUMMARY
    #=================================================
    log_section("TEST SUMMARY")
    
    success_rate = (passed_tests * 100 / total_tests) if total_tests > 0 else 0
    
    summary = f"""
{'=' * 60}
CLUBHOUSE FEATURES & STRESS TEST SUMMARY
{'=' * 60}

Test Date: {datetime.now()}
Duration: {time.time() - start_time:.2f}s

ENTITIES CREATED:
  Users:  {len(users)}/{NUM_USERS}
  Rooms:  {len(rooms)}/{NUM_ROOMS}

TEST RESULTS:
  Total Tests:   {total_tests}
  Passed:        {passed_tests}
  Failed:        {failed_tests}
  Success Rate:  {success_rate:.2f}%

FEATURES TESTED:
  ✓ User Registration & Authentication
  ✓ Ghost Profile Management
  ✓ Room Creation & Management
  ✓ Join/Leave Room
  ✓ Invite to Speak
  ✓ Following System
  ✓ Notifications & FCM
  ✓ Enhanced Discovery (Trending, Search)
  ✓ Concurrent Room Joins (Stress Test)

{'=' * 60}
Log File: {LOG_FILE}
{'=' * 60}
"""
    
    # Write summary to file
    with open(SUMMARY_FILE, 'w') as f:
        f.write(summary)
    
    # Print colored summary
    print()
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    print(f"{Colors.BLUE}CLUBHOUSE FEATURES & STRESS TEST SUMMARY{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    print()
    print(f"ENTITIES CREATED:")
    print(f"  Users:  {Colors.GREEN}{len(users)}/{NUM_USERS}{Colors.NC}")
    print(f"  Rooms:  {Colors.GREEN}{len(rooms)}/{NUM_ROOMS}{Colors.NC}")
    print()
    print(f"TEST RESULTS:")
    print(f"  Total Tests:   {Colors.YELLOW}{total_tests}{Colors.NC}")
    print(f"  Passed:        {Colors.GREEN}{passed_tests}{Colors.NC}")
    print(f"  Failed:        {Colors.RED}{failed_tests}{Colors.NC}")
    print(f"  Success Rate:  {Colors.YELLOW}{success_rate:.2f}%{Colors.NC}")
    print()
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    print(f"Full Log: {Colors.YELLOW}{LOG_FILE}{Colors.NC}")
    print(f"Summary:  {Colors.YELLOW}{SUMMARY_FILE}{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    
    sys.exit(0 if failed_tests == 0 else 1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Test interrupted by user{Colors.NC}")
        sys.exit(1)
    except Exception as e:
        print(f"\n{Colors.RED}Fatal error: {e}{Colors.NC}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
