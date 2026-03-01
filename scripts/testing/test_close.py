import requests
import sys

BASE_URL = "https://vivaclubs.site"
USERNAME = "admin"
PASSWORD = "AdminPassword123!"

res = requests.post(f"{BASE_URL}/api/auth/login/", json={"username": USERNAME, "password": PASSWORD})
token = res.json().get("access")

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

data = res.json()
rooms = data.get("results", data) if isinstance(data, dict) else data

if len(rooms) > 0:
    room_id = rooms[0].get("id")
    print(f"Trying to close room {room_id}...")
    
    close_res = requests.post(
        f"{BASE_URL}/api/community/admin/rooms/{room_id}/close/", 
        headers=headers
    )
    print(f"STATUS: {close_res.status_code}")
    print(f"RESPONSE:\n{close_res.text}")
else:
    print("No active rooms to try closing.")
