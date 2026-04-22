import requests
import concurrent.futures
import uuid
import json

BASE_URL = "https://vivaclubs.site/api"
TEST_USERS_COUNT = 10
PASSWORD = "password123"

def register_and_login(index):
    username = f"stress_user_{index}_{uuid.uuid4().hex[:6]}"
    # Register
    reg_data = {
        "username": username,
        "password": PASSWORD,
        "email": f"{username}@stress.com",
        "display_name": f"Stress User {index}",
        "role": "patient"
    }
    requests.post(f"{BASE_URL}/auth/register/", json=reg_data)
    
    # Login
    login_data = {"username": username, "password": PASSWORD}
    resp = requests.post(f"{BASE_URL}/auth/login/", json=login_data)
    if resp.status_code == 200:
        return resp.json()['access']
    return None

def book_slot(token, slot_id):
    headers = {"Authorization": f"Bearer {token}"}
    data = {"slot": slot_id}
    resp = requests.post(f"{BASE_URL}/clinical/appointments/", json=data, headers=headers)
    return resp.status_code, resp.text

def run_stress_test():
    print(f"🚀 Preparing {TEST_USERS_COUNT} users for stress test...")
    with concurrent.futures.ThreadPoolExecutor(max_workers=TEST_USERS_COUNT) as executor:
        tokens = list(executor.map(register_and_login, range(TEST_USERS_COUNT)))
    
    tokens = [t for t in tokens if t]
    print(f"✅ Logged in {len(tokens)} users.")

    # 1. Get an available slot
    headers = {"Authorization": f"Bearer {tokens[0]}"}
    doctors_resp = requests.get(f"{BASE_URL}/clinical/doctors/", headers=headers)
    doctors = doctors_resp.json()
    if not doctors:
        print(f"❌ No doctors found. Response: {doctors_resp.text}")
        return

    doctor_id = doctors[0]['id']
    slots_resp = requests.get(f"{BASE_URL}/clinical/timeslots/?doctor_id={doctor_id}", headers=headers)
    slots = slots_resp.json()
    if not slots:
        print(f"❌ No slots found for doctor {doctor_id}.")
        return

    target_slot_id = slots[0]['id']
    print(f"🎯 Target Slot ID: {target_slot_id} (Doctor: {doctors[0]['display_name']})")
    print(f"🔥 Starting race condition attack with {len(tokens)} simultaneous requests...")

    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(tokens)) as executor:
        # Submit all requests at once
        future_to_token = {executor.submit(book_slot, token, target_slot_id): token for token in tokens}
        for future in concurrent.futures.as_completed(future_to_token):
            results.append(future.result())

    # Analyze results
    success_count = len([r for r in results if r[0] == 201])
    fail_count = len([r for r in results if r[0] != 201])

    print("\n--- Stress Test Results ---")
    print(f"✅ Success (201 Created): {success_count}")
    print(f"❌ Failed (Expected for Race Condition): {fail_count}")

    if success_count == 1:
        print("\n🏆 PASS: Race condition prevented. Exactly one user booked the slot.")
    elif success_count > 1:
        print(f"\n💀 FAIL: CRITICAL VULNERABILITY! {success_count} users managed to book the SAME slot.")
    else:
        print("\n⚠️  Unexpected result: No one succeeded. Check server logs.")

    # Show some fail messages
    if fail_count > 0:
        print(f"Sample error from server: {results[-1][1]}")

if __name__ == "__main__":
    run_stress_test()
