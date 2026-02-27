#!/usr/bin/env python3
import asyncio
import os
import requests
import json
import time
from pathlib import Path # Added for LOG_DIR
from livekit import rtc # Removed 'api' as per instruction snippet

# Configuration
BASE_URL = "https://vivaclubs.site"
LOG_DIR = Path("./test_logs")

# Helper checks
def check(response, code=200):
    if response.status_code != code:
        print(f"❌ Failed: {response.status_code} - {response.text}")
        return False
    return True

async def run_test():
    print("=== Testing Room Interactions with REAL LiveKit Connection ===")
    
    # 1. Setup Accounts & Room
    print("\n1. Setting up Environment...")
    
    # Create Host
    host_data = {"username": f"host_int_{os.urandom(4).hex()}", "password": "password123", "email": f"host_{os.urandom(4).hex()}@test.com"}
    requests.post(f"{BASE_URL}/api/auth/register/", json=host_data)
    res = requests.post(f"{BASE_URL}/api/auth/login/", json={"username": host_data["username"], "password": "password123"})
    host_token = res.json()['access']
    print(f"   Host: {host_data['username']}")

    # Create Listener
    list_data = {"username": f"list_int_{os.urandom(4).hex()}", "password": "password123", "email": f"list_{os.urandom(4).hex()}@test.com"}
    requests.post(f"{BASE_URL}/api/auth/register/", json=list_data)
    res = requests.post(f"{BASE_URL}/api/auth/login/", json={"username": list_data["username"], "password": "password123"})
    list_token = res.json()['access']
    print(f"   Listener: {list_data['username']}")

    # Create Room
    res = requests.post(f"{BASE_URL}/api/community/rooms/", json={"title": "Interaction Test Room"}, headers={"Authorization": f"Bearer {host_token}"})
    room_id = res.json()['id']
    print(f"   Room ID: {room_id}")

    # 2. Connect BOTH to LiveKit
    print("\n2. Connecting Users to LiveKit...")
    
    # Get Tokens
    res_h = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/join/", headers={"Authorization": f"Bearer {host_token}"})
    host_lk_token = res_h.json()['token']
    host_ws_url = res_h.json()['url']

    res_l = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/join/", headers={"Authorization": f"Bearer {list_token}"})
    list_lk_token = res_l.json()['token']
    list_identity = res_l.json()['identity']
    
    # Connect
    room_host = rtc.Room()
    room_listener = rtc.Room()

    # Event Handlers
    @room_host.on("participant_metadata_changed")
    def on_meta_changed(participant, old_metadata, _):
        if participant.identity == list_identity:
            print(f"   🔔 HOST SAW: Listener metadata changed: {participant.metadata}")

    @room_listener.on("participant_permission_changed")
    def on_perm_changed(participant, old_permissions, _):
        print(f"   🔔 LISTENER SAW: Permissions updated! Can Publish: {participant.permissions.can_publish}")

    @room_listener.on("disconnected")
    def on_disconnected(reason):
        print(f"   🔔 LISTENER SAW: Disconnected! Reason: {reason}")
    
    @room_listener.on("track_muted")
    def on_track_muted(pub, _):
        print(f"   🔔 LISTENER SAW: Track Muted! {pub.sid}")

    try:
        await room_host.connect(host_ws_url, host_lk_token)
        await room_listener.connect(host_ws_url, list_lk_token)
        print("   ✅ Both Users Connected!")
        await asyncio.sleep(2)

        # 3. Test Hand Raise (Metadata)
        print("\n3. Testing Hand Raise (Client -> Metadata -> Host)...")
        # Listener sets metadata
        await room_listener.local_participant.set_metadata(json.dumps({"handRaised": True}))
        await asyncio.sleep(2) # Wait for event on host
        
        # 4. Test Approve Speaker (Invite API)
        print("\n4. Testing Approve Speaker (Host API -> Listener)...")
        res = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/invite/", 
            json={"identity": list_identity},
            headers={"Authorization": f"Bearer {host_token}"}
        )
        if check(res): print(f"   ✅ API Call Success")
        await asyncio.sleep(2)

        # 5. Test Mute Speaker (Mute API)
        print("\n5. Testing Mute Speaker (Host API -> Listener)...")
        # First, Listener publishes a dummy track so we can mute it
        # Note: In a script without real media, we might not be able to publish a track easily without a source.
        # But we can try to mute the participant generally? No, LiveKit mutes distinct tracks.
        # Let's skip publishing and just call the API to see if it returns 404 (track not found) or success.
        # If we didn't publish, we can't mute a track.
        # However, we can call the API and verify it handles "no track" gracefully or look for a specific error.
        # Wait, the API I wrote requires `track_sid`.
        # Since I can't easily publish a track from python script without a media source, 
        # I will test the "Kick" functionality which is track-independent.
        print("   ℹ️  Skipping Mute test (requires active media track)")

        # 6. Test Kick Participant (Kick API)
        print("\n6. Testing Kick Participant (Host API -> Listener)...")
        res = requests.post(f"{BASE_URL}/api/community/rooms/{room_id}/kick-participant/", 
            json={"identity": list_identity},
            headers={"Authorization": f"Bearer {host_token}"}
        )
        if check(res): print(f"   ✅ API Call Success")
        await asyncio.sleep(2)
        
        # Verify Disconnection
        # Verify Disconnection
        # print(f"Connection State: {room_listener.connection_state}")
        # ConnectionState enum members might be different in this version
        if str(room_listener.connection_state) == 'ConnectionState.DISCONNECTED':
             print("   ✅ Listener was disconnected!")
        else:
             print(f"   ⚠️ Listener state: {room_listener.connection_state}")

    except Exception as e:
        print(f"   ❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        await room_host.disconnect()
        await room_listener.disconnect()

if __name__ == "__main__":
    asyncio.run(run_test())
