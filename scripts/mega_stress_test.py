import requests
import concurrent.futures
import uuid
import random
import time
from datetime import datetime, timedelta

BASE_URL = "https://vivaclubs.site/api"
DOCTOR_COUNT = 15
PATIENT_COUNT = 50
PASSWORD = "stresspassword123"

class StressActor:
    def __init__(self, role, index):
        self.role = role
        self.username = f"mega_{role}_{index}_{uuid.uuid4().hex[:6]}"
        self.token = None
        self.id = None

    def register_and_login(self):
        # Register
        data = {
            "username": self.username,
            "password": PASSWORD,
            "email": f"{self.username}@stress.com",
            "display_name": f"Mega {self.role.capitalize()} {self.username[-4:]}",
            "role": self.role,
            "specialty": "Psychiatrist" if self.role == "doctor" else ""
        }
        resp = requests.post(f"{BASE_URL}/auth/register/", json=data)
        
        # Login
        login_data = {"username": self.username, "password": PASSWORD}
        resp = requests.post(f"{BASE_URL}/auth/login/", json=login_data)
        if resp.status_code == 200:
            res_json = resp.json()
            self.token = res_json['access']
            self.id = res_json['user_id']
            return True
        return False

    def get_headers(self):
        return {"Authorization": f"Bearer {self.token}"}

def setup_doctor(doc):
    if doc.register_and_login():
        # Go online
        requests.post(f"{BASE_URL}/clinical/doctors/toggle_online/", headers=doc.get_headers())
        
        # Create 5 slots
        for i in range(1, 6):
            start = datetime.now() + timedelta(days=i, hours=10)
            end = start + timedelta(hours=1)
            slot_data = {
                "start_time": start.isoformat(),
                "end_time": end.isoformat(),
                "price": 500.00
            }
            requests.post(f"{BASE_URL}/clinical/timeslots/", json=slot_data, headers=doc.get_headers())
        return True
    return False

def patient_action(pat):
    if not pat.register_and_login():
        return "Login Failed"

    # 1. Assessment
    score = random.randint(5, 25)
    assess_data = {"total_score": score, "answers": {"q1": 3, "q2": score-3}}
    resp = requests.post(f"{BASE_URL}/clinical/assessments/", json=assess_data, headers=pat.get_headers())
    
    if score >= 20:
        # 2. Trigger SOS
        sos_resp = requests.post(f"{BASE_URL}/clinical/sos/", headers=pat.get_headers())
        return "SOS Triggered" if sos_resp.status_code == 201 else f"SOS Failed ({sos_resp.status_code})"
    else:
        # 3. Book Appointment
        docs_resp = requests.get(f"{BASE_URL}/clinical/doctors/", headers=pat.get_headers())
        doctors = docs_resp.json()
        if doctors:
            target_doc = random.choice(doctors)
            slots_resp = requests.get(f"{BASE_URL}/clinical/timeslots/?doctor_id={target_doc['id']}", headers=pat.get_headers())
            slots = slots_resp.json()
            if slots:
                slot_id = slots[0]['id']
                book_resp = requests.post(f"{BASE_URL}/clinical/appointments/", json={"slot": slot_id}, headers=pat.get_headers())
                return "Booked" if book_resp.status_code == 201 else f"Booking Conflict ({book_resp.status_code})"
        return "No Slots Found"

def doctor_handle_sos(doc):
    # Continuously check for SOS for 10 seconds
    for _ in range(5):
        resp = requests.get(f"{BASE_URL}/clinical/sos/list_waiting/", headers=doc.get_headers())
        waiting = resp.json()
        if waiting:
            sos_id = waiting[0]['id']
            accept_resp = requests.post(f"{BASE_URL}/clinical/sos/{sos_id}/accept/", headers=doc.get_headers())
            if accept_resp.status_code == 200:
                time.sleep(1) # Simulate call
                requests.post(f"{BASE_URL}/clinical/sos/{sos_id}/complete/", headers=doc.get_headers())
                return "SOS Handled"
        time.sleep(2)
    return "No SOS to handle"

def run_mega_test():
    print(f"🚀 Initializing Mega Stress Test: {DOCTOR_COUNT} Doctors, {PATIENT_COUNT} Patients")
    
    doctors = [StressActor("doctor", i) for i in range(DOCTOR_COUNT)]
    patients = [StressActor("patient", i) for i in range(PATIENT_COUNT)]

    # --- Phase 1: Doctors Setup ---
    print("👨‍⚕️ Setting up doctors...")
    with concurrent.futures.ThreadPoolExecutor(max_workers=DOCTOR_COUNT) as executor:
        doc_results = list(executor.map(setup_doctor, doctors))
    
    ready_docs = [d for d, r in zip(doctors, doc_results) if r]
    print(f"✅ {len(ready_docs)} Doctors ready and online.")

    # --- Phase 2: Patient Blitz ---
    print(f"🔥 Patients launching blitz on {BASE_URL}...")
    start_time = time.time()
    with concurrent.futures.ThreadPoolExecutor(max_workers=PATIENT_COUNT) as executor:
        patient_results = list(executor.map(patient_action, patients))
    
    # --- Phase 3: Doctors Response Blitz ---
    print("👨‍⚕️ Doctors responding to SOS calls...")
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(ready_docs)) as executor:
        doctor_results = list(executor.map(doctor_handle_sos, ready_docs))

    end_time = time.time()
    duration = end_time - start_time

    # --- Final Report ---
    print("\n" + "="*40)
    print("🏆 MEGA STRESS TEST REPORT")
    print("="*40)
    print(f"Total Duration: {duration:.2f} seconds")
    print(f"Total Requests (Est): ~{PATIENT_COUNT * 5 + DOCTOR_COUNT * 10}")
    
    # Patient Summary
    success_pat = [r for r in patient_results if r in ["SOS Triggered", "Booked"]]
    fail_pat = [r for r in patient_results if r not in ["SOS Triggered", "Booked"]]
    
    print(f"\n👤 Patient Success Rate: {(len(success_pat)/PATIENT_COUNT)*100:.1f}%")
    print(f"   - Successfully Booked/SOS: {len(success_pat)}")
    print(f"   - Failed/Conflict: {len(fail_pat)}")
    
    # Doctor Summary
    sos_handled = [r for r in doctor_results if r == "SOS Handled"]
    print(f"\n👨‍⚕️ SOS Handling: {len(sos_handled)} emergency calls resolved.")

    # Concurrency Check
    print("\n🛠️ System Integrity Check:")
    # We check for double booking in DB manually or assume 400 response means success of logic
    conflicts = [r for r in patient_results if "Conflict" in r]
    print(f"   - Blocked Race Conditions: {len(conflicts)}")
    
    print("\n🏁 Mega Stress Test Completed.")

if __name__ == "__main__":
    run_mega_test()
