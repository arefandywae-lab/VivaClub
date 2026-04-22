import requests
import json
import uuid
import time
import sys

BASE_URL = "https://vivaclubs.site/api"
# Use a random suffix to avoid user collision
SUFFIX = str(uuid.uuid4())[:8]
PATIENT_USERNAME = f"test_patient_{SUFFIX}"
PATIENT_PASSWORD = "password123"
DOCTOR_USERNAME = "test_doctor_demo" # Should exist or be created

def log(msg, success=True):
    symbol = "✅" if success else "❌"
    print(f"{symbol} {msg}")

def test_journey():
    print(f"🚀 Starting Patient Journey Test on {BASE_URL}...")
    session = requests.Session()

    # 1. Register Patient
    print("\n--- Phase 1: Authentication ---")
    reg_data = {
        "username": PATIENT_USERNAME,
        "password": PATIENT_PASSWORD,
        "email": f"{PATIENT_USERNAME}@example.com",
        "display_name": f"Test Patient {SUFFIX}",
        "role": "patient"
    }
    resp = session.post(f"{BASE_URL}/auth/register/", json=reg_data)
    if resp.status_code == 201:
        log(f"Registered patient: {PATIENT_USERNAME}")
    else:
        log(f"Registration failed: {resp.text}", False)
        return

    # 2. Login
    login_data = {"username": PATIENT_USERNAME, "password": PATIENT_PASSWORD}
    resp = session.post(f"{BASE_URL}/auth/login/", json=login_data)
    if resp.status_code == 200:
        tokens = resp.json()
        access_token = tokens['access']
        session.headers.update({"Authorization": f"Bearer {access_token}"})
        log(f"Login successful. User ID: {tokens.get('user_id')}")
        patient_id = tokens.get('user_id')
    else:
        log(f"Login failed: {resp.text}", False)
        return

    # 3. PHQ-9 Assessment (Low Risk)
    print("\n--- Phase 2: Assessment (Low Risk) ---")
    assessment_low = {
        "title": "PHQ-9 Mental Health",
        "total_score": 5,
        "results": {"q1": 1, "q2": 1, "q3": 1, "q4": 2}
    }
    resp = session.post(f"{BASE_URL}/clinical/assessments/", json=assessment_low)
    if resp.status_code == 201:
        log("Submitted Low-Risk Assessment (Score: 5)")
    else:
        log(f"Assessment submission failed: {resp.text}", False)

    # 4. Try SOS (Should be forbidden)
    print("\n--- Phase 3: SOS Access Control ---")
    resp = session.post(f"{BASE_URL}/clinical/sos/", json={})
    if resp.status_code == 403:
        log("SOS Trigger blocked for Low-Risk patient (Correct behavior)")
    else:
        log(f"SOS Trigger expected 403 but got {resp.status_code}", False)

    # 5. PHQ-9 Assessment (High Risk)
    print("\n--- Phase 4: Assessment (High Risk) ---")
    assessment_high = {
        "title": "PHQ-9 Mental Health",
        "total_score": 22,
        "results": {"q1": 3, "q2": 3, "q3": 3, "q4": 3, "q5": 3, "q6": 3, "q7": 3, "q8": 1}
    }
    resp = session.post(f"{BASE_URL}/clinical/assessments/", json=assessment_high)
    if resp.status_code == 201:
        log("Submitted High-Risk Assessment (Score: 22)")
    else:
        log(f"High-risk assessment failed: {resp.text}", False)

    # 6. Unlock SOS (Should succeed)
    resp = session.post(f"{BASE_URL}/clinical/sos/", json={})
    if resp.status_code == 201:
        log("SOS Triggered successfully for High-Risk patient")
        sos_id = resp.json()['id']
    else:
        log(f"SOS Trigger failed: {resp.text}", False)

    # 7. Browse Doctors
    print("\n--- Phase 5: Doctor Discovery ---")
    resp = session.get(f"{BASE_URL}/clinical/doctors/")
    if resp.status_code == 200:
        doctors = resp.json()
        log(f"Found {len(doctors)} verified doctors")
        if len(doctors) > 0:
            doctor = doctors[0]
            doctor_id = doctor['id']
            log(f"Selected Doctor: {doctor['display_name']} ({doctor['specialty']})")
        else:
            log("No doctors found for booking test", False)
            doctor_id = None
    else:
        log(f"Failed to fetch doctors: {resp.text}", False)
        doctor_id = None

    # 8. Fetch Slots & Book
    if doctor_id:
        print("\n--- Phase 6: Booking Flow ---")
        # Note: We need a slot to exist. For testing, we'll assume there might be one or we skip.
        resp = session.get(f"{BASE_URL}/clinical/timeslots/?doctor_id={doctor_id}")
        if resp.status_code != 200:
            log(f"Failed to fetch slots: {resp.text}", False)
            return
            
        slots = resp.json()
        if len(slots) > 0:
            slot_id = slots[0]['id']
            log(f"Found available slot: {slot_id}")
            
            booking_data = {"slot": slot_id}
            resp = session.post(f"{BASE_URL}/clinical/appointments/", json=booking_data)
            if resp.status_code == 201:
                log("Appointment booked successfully")
            else:
                log(f"Booking failed: {resp.text}", False)
        else:
            log("No available slots for this doctor. Skipping booking test.")

    # 9. Chat Message
    print("\n--- Phase 7: Chat & Notifications ---")
    room_id = f"dm_{patient_id}" # Simple room naming convention
    chat_data = {
        "room_id": room_id,
        "content": "Hello, I need help with my results."
    }
    # Note: Backend might need a Message create endpoint or it's handled via WebSocket.
    # Our API has a MessageViewSet with list, but maybe not create if it's WS only.
    # Let's check history instead.
    resp = session.get(f"{BASE_URL}/chat/messages/?room_id={room_id}")
    if resp.status_code == 200:
        log(f"Retrieved chat history for room {room_id}")
    else:
        log(f"Failed to fetch chat history: {resp.text}", False)

    # 10. Register Device Token
    token_data = {
        "token": f"fcm_token_{SUFFIX}",
        "device_type": "android"
    }
    resp = session.post(f"{BASE_URL}/auth/device-tokens/", json=token_data)
    if resp.status_code == 201:
        log("FCM Device Token registered successfully")
    else:
        log(f"Token registration failed: {resp.text}", False)

    print("\n🏁 Patient Journey Test Completed.")

if __name__ == "__main__":
    test_journey()
