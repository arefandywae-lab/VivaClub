import requests
import sys

BASE_URL = "https://vivaclubs.site"
USERNAME = "admin"
PASSWORD = "vivaclub_admin_1234"

def test_admin_api():
    print("1. Logging in...")
    login_url = f"{BASE_URL}/api/auth/login/"
    res = requests.post(login_url, json={"username": USERNAME, "password": PASSWORD})
    
    if res.status_code != 200:
        print(f"Login failed: {res.status_code}")
        print(res.text)
        sys.exit(1)
        
    token = res.json().get("access")
    print("Login successful! Got token.")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Get active rooms
    print("\n2. Fetching rooms...")
    res = requests.get(f"{BASE_URL}/api/community/rooms/", headers=headers)
    
    if res.status_code != 200:
        print(f"Failed to fetch rooms: {res.status_code}")
        sys.exit(1)
        
    data = res.json()
    rooms = data.get("results", data)
    
    if not isinstance(rooms, list):
        print(f"Unexpected rooms format: {type(rooms)}")
        sys.exit(1)
        
    print(f"Found {len(rooms)} active rooms.")
    
    if len(rooms) == 0:
        print("No active rooms. Can't test close action. Exiting peacefully.")
        sys.exit(0)
        
    room_id = rooms[0].get("id")
    print(f"\n3. Testing Admin GET participants for room {room_id}...")
    res = requests.get(f"{BASE_URL}/api/community/admin/rooms/{room_id}/participants/", headers=headers)
    print(f"Status: {res.status_code}")
    print(f"Response: {res.text[:200]}")
    
    print(f"\n4. Testing Admin POST close for room {room_id}...")
    # NOTE: Normally we don't want to close a live room, but for testing if 403 occurs:
    # Actually wait, let's just make a dummy POST to a bad action just to see if 403 or 400
    res = requests.post(f"{BASE_URL}/api/community/admin/rooms/{room_id}/dummy/", headers=headers)
    print(f"Status: {res.status_code}")
    print(f"Response: {res.text[:200]}")

if __name__ == "__main__":
    test_admin_api()
