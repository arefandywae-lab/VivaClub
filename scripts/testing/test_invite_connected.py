#!/usr/bin/env python3
import asyncio
import os
import requests
from livekit import rtc

# Set this to your local or prod URL
BASE_URL = "https://vivaclubs.site"

# Helper checks
def check(response, code=200):
    if response.status_code != code:
        print(f"❌ Failed: {response.status_code} - {response.text}")
        return False
    return True

async def run_test():
    print("=== Testing Invite Flow with REAL LiveKit Connection ===")
    
    # 1. Create Listener Account
    print("\n1. Creating Listener...")
    listener_data = {
        "username": f"list_conn_{os.urandom(4).hex()}",
        "password": "password123",
        "email": f"list_{os.urandom(4).hex()}@test.com"
    }
    res = requests.post(f"{BASE_URL}/api/auth/register/", json=listener_data)
    if not check(res, 201): return
    
    # Login Listener
    res = requests.post(f"{BASE_URL}/api/auth/login/", json={
        "username": listener_data["username"], "password": "password123"
    })
    listener_token = res.json()['access']
    print(f"   Listener created: {listener_data['username']}")

    # 2. Create Host Account
    print("\n2. Creating Host...")
    host_data = {
        "username": f"host_conn_{os.urandom(4).hex()}",
        "password": "password123",
        "email": f"host_{os.urandom(4).hex()}@test.com"
    }
    requests.post(f"{BASE_URL}/api/auth/register/", json=host_data)
    
    # Login Host
    res = requests.post(f"{BASE_URL}/api/auth/login/", json={
        "username": host_data["username"], "password": "password123"
    })
    host_token = res.json()['access']
    print(f"   Host created: {host_data['username']}")

    # 3. Create Room (Host)
    print("\n3. Creating Room...")
    res = requests.post(f"{BASE_URL}/api/community/rooms/", json={
        "title": "Real Connection Test Room"
    }, headers={"Authorization": f"Bearer {host_token}"})
    if not check(res, 201): return
    room_id = res.json()['id']
    print(f"   Room ID: {room_id}")

    # 4. Listener Joins (Get Token)
    print("\n4. Listener Getting Token...")
    res = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/join/", 
        headers={"Authorization": f"Bearer {listener_token}"})
    if not check(res, 200): return
    
    data = res.json()
    ws_url = data['url']
    lk_token = data['token']
    identity = data['identity']
    print(f"   Got LiveKit Token for identity: {identity}")

    # 5. Connect Listener to LiveKit
    print("\n5. Connecting Listener to LiveKit Room...")
    room = rtc.Room()
    
    @room.on("participant_connected")
    def on_participant_connected(participant):
        print(f"   EVENT: Participant connected: {participant.identity}")

    @room.on("participant_permission_changed")
    def on_permission_changed(participant, old_permissions, is_participant_publisher):
        print(f"   EVENT: Permissions changed for {participant.identity}")
        print(f"          Can Publish: {participant.permissions.can_publish}")

    try:
        await room.connect(ws_url, lk_token)
        print("   ✅ Listener Connected to LiveKit!")
        
        # Wait a bit for server to register presence
        await asyncio.sleep(2)

        # 6. Host Invites Listener
        print("\n6. Host Inviting Listener (API Call)...")
        res = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/invite/", 
            json={"identity": identity},
            headers={"Authorization": f"Bearer {host_token}"}
        )
        
        if res.status_code == 200:
            print("   ✅ Invite API Success (200 OK)")
            print(f"   Response: {res.json()}")
        else:
            print(f"   ❌ Invite API Failed: {res.status_code} - {res.text}")

        # Wait to capture any permission change events
        await asyncio.sleep(2)

    except Exception as e:
        print(f"   ❌ Connection Error: {e}")
    finally:
        print("\n7. Disconnecting...")
        await room.disconnect()

if __name__ == "__main__":
    asyncio.run(run_test())
