# บทที่ 10: การทดสอบและ QA
# Chapter 10: Testing and Quality Assurance

---

## สารบัญบท / Chapter Contents

10.1 กลยุทธ์การทดสอบ (Testing Strategy)  
10.2 Test Scripts อัตโนมัติ  
10.3 ผลการทดสอบ Stress Test  
10.4 API Endpoint Coverage Matrix  
10.5 การทดสอบบนอุปกรณ์จริง (Device Testing)  
10.6 Network Condition Testing  
10.7 ข้อจำกัดที่ทราบ (Known Gaps)  

---

## 10.1 กลยุทธ์การทดสอบ

### ทำไมไม่ใช้ Unit Tests แบบ Traditional

ทีมพัฒนา 2 คน มีเวลาจำกัด เลือกกลยุทธ์ที่ **ROI สูงที่สุด:**

| Approach | เลือก | เหตุผล |
|----------|-------|--------|
| Django unit tests | ❌ | Model logic ง่าย, ครอบคลุมโดย integration tests |
| Flutter widget tests | ❌ | UI เปลี่ยนบ่อย, setup overhead สูง |
| Integration test scripts | ✅ | ทดสอบ real API บน production server โดยตรง |
| Stress test scripts | ✅ | ทดสอบ concurrent users ที่สำคัญมาก |
| Manual device testing | ✅ | UI/UX validation บน real devices |
| Network condition testing | ✅ | Critical สำหรับ Thai carriers |

**ผลลัพธ์:** Integration tests ให้ความมั่นใจสูงกว่า unit tests สำหรับ API-driven app เพราะทดสอบทุกอย่างรวมกัน (HTTP, auth, DB, business logic)

---

## 10.2 Test Scripts อัตโนมัติ

ทุก test script อยู่ที่ `scripts/` ทดสอบบน production URL `https://vivaclubs.site`

---

### Script 1: `test_patient_journey.py`

**วัตถุประสงค์:** End-to-end patient workflow ตั้งแต่สมัครจนถึง SOS

**สิ่งที่ทดสอบ:**

**ผลลัพธ์:**

---

### Script 2: `mega_stress_test.py`

**วัตถุประสงค์:** Load test ด้วย concurrent users, doctors, และ bookings

**Configuration:**

**สิ่งที่ทดสอบ:**
1. **Concurrent Registration:** 50 patients + 15 doctors สมัครพร้อมกัน
2. **Concurrent Slot Creation:** 15 doctors สร้าง time slots พร้อมกัน (5 slots ต่อคน = 75 slots)
3. **Concurrent Booking:** 20 patients พยายาม book slot เดียวกันพร้อมกัน
4. **Race Condition Verification:** มีแค่คนเดียวที่ booking สำเร็จ คนที่เหลือได้ 400

**ผลลัพธ์ที่บันทึกไว้ (จาก VPS deployment report):**

---

### Script 3: `stress_test_race_condition.py`

**วัตถุประสงค์:** Test atomic booking ป้องกัน double-booking

**Method:** ใช้ `concurrent.futures.ThreadPoolExecutor` ส่ง requests พร้อมกัน:

**ผลลัพธ์:** ผ่าน 100% — atomic locking (`select_for_update()`) ทำงานได้สมบูรณ์

---

### Script 4: `testing/test_clubhouse.py`

**วัตถุประสงค์:** ทดสอบ Community Room API ครบถ้วน

**สิ่งที่ทดสอบ:**
- Create room with profanity in title → 400 Bad Request
- Create room with valid data → 201 Created
- Join room → receive LiveKit token
- Follow/Unfollow ghost profile
- Room discovery: filter by category
- Report user in room
- Block/Unblock user

---

### Script 5: `testing/test_interactions_connected.py`

**วัตถุประสงค์:** ทดสอบ LiveKit room interactions

**สิ่งที่ทดสอบ:**
- Invite speaker → verify LiveKit `can_publish = true`
- Mute participant → verify track muted
- Kick participant → verify removed
- Promote to moderator

---

### Script 6: `verify_livekit_token.py`

**วัตถุประสงค์:** ตรวจสอบความถูกต้องของ LiveKit JWT tokens

---

## 10.3 ผลการทดสอบ Stress Test

**ทดสอบเมื่อ:** กุมภาพันธ์ 2569 (post VPS migration)  
**Environment:** Contabo VPS (4 vCPU / 8 GB RAM)

---

## 10.4 API Endpoint Coverage Matrix

| Endpoint | Test Method | Status |
|----------|-------------|--------|
| POST /auth/register/ | Automated | ✅ Pass |
| POST /auth/login/ | Automated | ✅ Pass |
| GET /auth/profile/ | Automated | ✅ Pass |
| PATCH /auth/profile/ | Manual | ✅ Pass |
| POST /auth/verify-email/ | Manual | ✅ Pass |
| POST /auth/forgot-password/ | Manual | ✅ Pass |
| POST /auth/device-tokens/ | Automated | ✅ Pass |
| GET /community/rooms/ | Automated | ✅ Pass |
| POST /community/rooms/ | Automated | ✅ Pass |
| POST /community/rooms/{id}/join/ | Automated | ✅ Pass |
| POST /community/rooms/{id}/invite/ | Automated | ✅ Pass |
| POST /community/rooms/{id}/kick/ | Automated | ✅ Pass |
| GET /community/ghosts/me/ | Automated | ✅ Pass |
| POST /community/ghosts/{id}/follow/ | Automated | ✅ Pass |
| GET /community/subscriptions/feed/ | Automated | ✅ Pass |
| GET /community/notifications/ | Manual | ✅ Pass |
| POST /community/reports/ | Automated | ✅ Pass |
| POST /community/blocks/ | Automated | ✅ Pass |
| GET /community/trust-score/me/ | Automated | ✅ Pass |
| POST /clinical/assessments/ | Automated | ✅ Pass |
| GET /clinical/doctors/ | Automated | ✅ Pass |
| POST /clinical/doctors/toggle-online/ | Automated | ✅ Pass |
| GET /clinical/doctors/dashboard/ | Automated | ✅ Pass |
| GET /clinical/timeslots/ | Automated | ✅ Pass |
| POST /clinical/timeslots/ | Automated | ✅ Pass |
| POST /clinical/appointments/ | Automated | ✅ Pass |
| POST /clinical/appointments/{id}/confirm/ | Manual | ✅ Pass |
| POST /clinical/appointments/{id}/join-call/ | Manual | ✅ Pass |
| POST /clinical/sos/ | Automated | ✅ Pass |
| GET /clinical/sos/my_position/ | Manual | ✅ Pass |
| POST /clinical/sos/{id}/accept/ | Manual | ✅ Pass |
| POST /clinical/opd-notes/ | Manual | ✅ Pass |
| GET /chat/messages/ | Automated | ✅ Pass |
| POST /chat/messages/mark_read/ | Automated | ✅ Pass |
| POST /community/webhook/livekit/ | Automated (via LiveKit events) | ✅ Pass |

**Total: 35 endpoints tested — 100% pass rate**

---

## 10.5 การทดสอบบนอุปกรณ์จริง

### iOS Testing

### Memory & Performance

---

## 10.6 Network Condition Testing

### Test Matrix

| Network | Audio Quality | Notes |
|---------|---------------|-------|
| WiFi (home) | ✅ Excellent | < 50ms latency |
| 4G AIS | ✅ Good (after TURN fix) | ~150ms latency |
| 4G True | ✅ Good (after TURN fix) | ~180ms latency |
| 4G DTAC | ✅ Good (after TURN fix) | ~160ms latency |
| 3G (weak signal) | ⚠️ Acceptable | ~400ms, occasional stutter |
| Airplane mode → reconnect | ✅ Reconnects | ~10s recovery time |

### TURN Fallback Test

---

## 10.7 ข้อจำกัดที่ทราบ (Known Testing Gaps)

| Gap | ผลกระทบ | แผนแก้ไข |
|-----|---------|---------|
| ไม่มี automated Flutter widget tests | UI regression ไม่ detected อัตโนมัติ | เพิ่มใน V2 (Flutter integration tests) |
| ไม่มี load test บน WebSocket layer | ไม่รู้ max concurrent WebSocket connections | เพิ่ม artillery.io test |
| ไม่มี automated LiveKit audio quality test | Audio quality validated manually เท่านั้น | เพิ่ม headless browser test |
| PHQ-9 clinical accuracy ไม่ได้ validate กับผู้เชี่ยวชาญ | ใช้ published scoring standard (Kroenke et al.) | หา clinical collaborator |
| Payment flow เป็น mock | Real payment integration ไม่ได้ทดสอบ | ทดสอบเมื่อ integrate Stripe/Omise |
| ไม่มี chaos engineering tests | ไม่รู้ behavior เมื่อ Redis/DB down | เพิ่มใน production hardening phase |
