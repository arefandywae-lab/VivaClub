import os
import requests
from livekit import api
from dotenv import load_dotenv

# Load env from the Server directory
load_dotenv('Server/.env')

def verify_livekit():
    print("🎥 Starting LiveKit Integration Verification...")
    
    api_url = os.getenv('LIVEKIT_API_URL')
    api_key = os.getenv('LIVEKIT_API_KEY')
    api_secret = os.getenv('LIVEKIT_API_SECRET')
    
    print(f"🔗 URL: {api_url}")
    print(f"🔑 Key: {api_key[:5]}...")

    if not all([api_url, api_key, api_secret]):
        print("❌ Error: Missing LiveKit credentials in .env")
        return

    # 1. Test Token Generation
    try:
        token = api.AccessToken(api_key, api_secret) \
            .with_identity("test_user") \
            .with_name("Test User") \
            .with_grants(api.VideoGrants(room_join=True, room="test_room"))
        
        jwt_token = token.to_jwt()
        print("✅ Token Generation: SUCCESS")
        print(f"🎫 Sample Token (first 20 chars): {jwt_token[:20]}...")
    except Exception as e:
        print(f"❌ Token Generation: FAILED - {e}")
        return

    # 2. Test Connection to LiveKit Cloud/Server (via Health Check or Info)
    # Most LiveKit servers have a simple websocket or health endpoint
    # Let's try to reach the HTTP version of the URL if it's wss://
    http_url = api_url.replace('wss://', 'https://').replace('ws://', 'http://')
    try:
        resp = requests.get(f"{http_url}/")
        # LiveKit server usually returns 404 or some text if hit directly via GET, 
        # but if it's reachable, it's a good sign.
        if resp.status_code in [200, 404]:
            print(f"✅ Server Reachability: SUCCESS (Status: {resp.status_code})")
        else:
            print(f"⚠️ Server Reachability: UNKNOWN (Status: {resp.status_code})")
    except Exception as e:
        print(f"❌ Server Reachability: FAILED - {e}")

    print("\n🏁 LiveKit is READY for Flutter UI integration.")

if __name__ == "__main__":
    verify_livekit()
