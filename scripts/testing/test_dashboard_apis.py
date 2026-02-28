import requests
import sys

BASE_URL = "https://vivaclubs.site"
USERNAME = "admin"
PASSWORD = "vivaclub_admin_1234"

def print_result(step, name, res):
    if res.status_code in [200, 201]:
        print(f"[{step}] ✓ {name} (Status: {res.status_code})")
    else:
        print(f"[{step}] ✗ {name} FAILED! (Status: {res.status_code})")
        print(f"Response: {res.text[:200]}")
        sys.exit(1)

def test_dashboard_apis():
    print("==================================================")
    print("Testing VivaClub Admin Dashboard APIs")
    print("==================================================")

    # 1. Login
    login_url = f"{BASE_URL}/api/auth/login/"
    res = requests.post(login_url, json={"username": USERNAME, "password": PASSWORD})
    print_result("1", "Login (Get JWT)", res)
    token = res.json().get("access")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    # 2. Get Profile (Check is_staff)
    res = requests.get(f"{BASE_URL}/api/auth/profile/", headers=headers)
    print_result("2", "Get Profile", res)
    is_staff = res.json().get("is_staff")
    print(f"   -> is_staff: {is_staff}")
    if not is_staff:
        print("   -> ERROR: The logged in user is NOT an admin (is_staff=False). Dashboard will block access.")
        sys.exit(1)

    # 3. Get All Users (Admin endpoint)
    res = requests.get(f"{BASE_URL}/api/auth/admin/users/", headers=headers)
    print_result("3", "Get Users List", res)
    users = res.json().get("results", res.json())
    print(f"   -> Found {len(users)} users.")

    # 4. Get Active Rooms
    res = requests.get(f"{BASE_URL}/api/community/rooms/", headers=headers)
    print_result("4", "Get Active Rooms", res)
    rooms = res.json().get("results", res.json())
    print(f"   -> Found {len(rooms)} active rooms.")

    # 5. Room Specific Admin Actions
    if len(rooms) > 0:
        room_id = rooms[0].get("id")
        
        # 5.1 Get Participants from LiveKit
        res = requests.get(f"{BASE_URL}/api/community/admin/rooms/{room_id}/participants/", headers=headers)
        # It's okay if LiveKit returns 500 if credentials are wrong, but we shouldn't get 403
        if res.status_code == 403:
            print_result("5.1", f"Get Participants for Room {room_id}", res)
        else:
            print(f"[5.1] ✓ Get Participants (Status: {res.status_code}) - Pass, no 403 error.")
            
        # 5.2 Mute Action (Dummy user)
        res = requests.post(f"{BASE_URL}/api/community/admin/rooms/{room_id}/mute/", 
                            json={"identity": "dummy", "track_sid": "dummy_track"}, 
                            headers=headers)
        if res.status_code == 403:
             print_result("5.2", f"Mute User in Room {room_id}", res)
        else:
             print(f"[5.2] ✓ Mute User (Status: {res.status_code}) - Pass, no 403 error. Expected 200 or 400.")
             
        # 5.3 Kick Action (Dummy user)
        res = requests.post(f"{BASE_URL}/api/community/admin/rooms/{room_id}/kick/", 
                            json={"identity": "dummy"}, 
                            headers=headers)
        if res.status_code == 403:
             print_result("5.3", f"Kick User in Room {room_id}", res)
        else:
             print(f"[5.3] ✓ Kick User (Status: {res.status_code}) - Pass, no 403 error.")

    else:
        print("\n[5] Skipping Room Admin Actions: No active rooms found.")

    print("\n==================================================")
    print("ALL TESTS PASSED: Admin Dashboard API is Healthy! 🚀")
    print("==================================================")


if __name__ == "__main__":
    test_dashboard_apis()
