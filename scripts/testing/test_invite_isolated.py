#!/usr/bin/env python3
import requests
import sys

# Target URL
BASE_URL = "https://vivaclubs.site"

def log(msg, color=""):
    print(f"{color}{msg}\033[0m")

def test_invite_flow():
    log("=== Testing Invite Flow (Isolated) ===", "\033[1;34m")
    
    # 1. Create Host
    log("1. Creating Host...", "\033[0;36m")
    host_res = requests.post(f"{BASE_URL}/api/auth/register/", json={
        "username": "host_iso_01", "password": "password123", 
        "email": "host_iso_01@test.com", "role": "patient", "first_name": "Host", "last_name": "One"
    })
    if host_res.status_code == 201:
        log("   Host created", "\033[0;32m")
        # Login
        host_login = requests.post(f"{BASE_URL}/api/auth/login/", json={
            "username": "host_iso_01", "password": "password123"
        })
        host_token = host_login.json()['access']
    else:
        # Try login if exists
        host_login = requests.post(f"{BASE_URL}/api/auth/login/", json={
            "username": "host_iso_01", "password": "password123"
        })
        if host_login.status_code != 200:
            log(f"   Failed to get host token: {host_login.text}", "\033[0;31m")
            return
        host_token = host_login.json()['access']
        log("   Host logged in (existing)", "\033[0;32m")

    # 2. Get Host Ghost ID
    host_ghost_res = requests.get(f"{BASE_URL}/api/community/ghosts/me/", headers={"Authorization": f"Bearer {host_token}"})
    host_ghost_id = host_ghost_res.json()['id']

    # 3. Create Listner
    log("2. Creating Listener...", "\033[0;36m")
    listener_res = requests.post(f"{BASE_URL}/api/auth/register/", json={
        "username": "list_iso_01", "password": "password123", 
        "email": "list_iso_01@test.com", "role": "patient", "first_name": "List", "last_name": "One"
    })
    if listener_res.status_code == 201:
        log("   Listener created", "\033[0;32m")
        listener_login = requests.post(f"{BASE_URL}/api/auth/login/", json={
            "username": "list_iso_01", "password": "password123"
        })
        listener_token = listener_login.json()['access']
    else:
        listener_login = requests.post(f"{BASE_URL}/api/auth/login/", json={
            "username": "list_iso_01", "password": "password123"
        })
        if listener_login.status_code != 200:
            log(f"   Failed to get listener token: {listener_login.text}", "\033[0;31m")
            return
        listener_token = listener_login.json()['access']
        log("   Listener logged in (existing)", "\033[0;32m")

    # 4. Create Room
    log("3. Creating Room...", "\033[0;36m")
    room_res = requests.post(f"{BASE_URL}/api/community/rooms/", json={
        "title": "Isolation Test Room", "category": "general", "tags": ["test"]
    }, headers={"Authorization": f"Bearer {host_token}"})
    
    if room_res.status_code not in [201, 400]:
        log(f"   Failed to create room: {room_res.text}", "\033[0;31m")
        return
        
    if room_res.status_code == 201:
        room_id = room_res.json()['id']
    else:
        # Search for it
        search = requests.get(f"{BASE_URL}/api/community/rooms/search/?q=Isolation", headers={"Authorization": f"Bearer {host_token}"})
        room_id = search.json()['rooms'][0]['id']

    log(f"   Room ID: {room_id}", "\033[0;32m")

    # 5. Join Room (Listener)
    log("4. Listener Joining Room...", "\033[0;36m")
    join_res = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/join/", headers={"Authorization": f"Bearer {listener_token}"})
    if join_res.status_code == 200:
        identity = join_res.json()['identity']
        log(f"   Joined. Identity: {identity}", "\033[0;32m")
    else:
        log(f"   Failed to join: {join_res.text}", "\033[0;31m")
        return

    # 6. Invite (Host invites Listener) - THIS IS WHAT FAILED RECENTLY
    log("5. Host Inviting Listener...", "\033[0;36m")
    invite_res = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/invite/", 
        json={"identity": identity}, 
        headers={"Authorization": f"Bearer {host_token}"}
    )
    
    if invite_res.status_code == 200:
        log("   ✓ Invite Successful (200 OK)", "\033[1;32m")
    else:
        log(f"   ✗ Invite Failed: {invite_res.status_code} - {invite_res.text}", "\033[1;31m")

if __name__ == "__main__":
    test_invite_flow()
