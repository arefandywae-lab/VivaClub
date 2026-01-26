# Viva Club: Backend, Data & Security Masterplan

เอกสารนี้รวบรวมโครงสร้างทางเทคนิคทั้งหมดของโปรเจค **Viva Club** ฉบับ Production-Ready โดยเน้นความปลอดภัย (Privacy-First) และความน่าเชื่อถือ (Reliability) สูงสุด

---

## 1. System Architecture (โครงสร้างระบบ)

เราใช้สถาปัตยกรรมแบบ **Hybrid Cloud** ที่เน้นของฟรีแต่ประสิทธิภาพสูง (High Performance, Zero Cost Startup)

| Layer | Technology | หน้าที่หลัก |
| :--- | :--- | :--- |
| **Backend API** | **Django (Python)** | จัดการ Logic หลัก, REST API, Auth, และ Admin Dashboard |
| **Database** | **PostgreSQL (Supabase)** | เก็บข้อมูล User, นัดหมาย, และ Chat Log (บางส่วน) |
| **Real-time** | **Django Channels + Redis** | ระบบ WebSocket สำหรับ Chat, Notification, และ Online Status |
| **Media Server** | **LiveKit Cloud** | หัวใจของระบบ Video Call (Telemed) และ Audio Room (Clubhouse) |
| **Cache/Lock** | **Upstash Redis** | จัดการ Booking Lock (กันจองซ้อน) และ Session ชั่วคราว |
| **Storage** | **Cloudinary** | เก็บไฟล์รูปภาพ (Profile Image, Attachments) |
| **Push Noti** | **Firebase (FCM)** | ปลุกแอปให้ตื่นเมื่อมีสายเข้า (VoIP Push) |

---

## 2. Key Logic Engines (ฟีเจอร์และกลไกสำคัญ)

### A. The "3-State Booking Machine" (ระบบจองคิวแบบกันชน)
ป้องกันปัญหาแย่งกันจอง (Race Condition) และการจองกั๊ก (Ghost Booking) ด้วยการแบ่งสถานะเป็น 3 ขั้น:

1.  **Available (ว่าง):** สถานะเริ่มต้น
2.  **Reserved (จองชั่วคราว):**
    *   เมื่อ User กดจอง ระบบจะสร้าง **Redis Key** (`lock:slot_id` TTL=5min)
    *   คนอื่นจะเห็นว่า "ไม่ว่าง" ทันที
    *   ถ้า User ไม่จ่ายเงิน/ยืนยันภายใน 5 นาที -> Redis Key หมดอายุ -> ดีดกลับเป็น **Available**
3.  **Confirmed (ยืนยันแล้ว):**
    *   เมื่อยืนยันสำเร็จ -> บันทึกลง Database ถาวร -> ลบ Redis Lock -> เปลี่ยนสถานะเป็น **CONFIRMED**

### B. Ghost Subscription (ระบบติดตามวิญญาณ) in Clubhouse
แก้ปัญหา Privacy ใน Community โดยแยก "ตัวตน" ออกจาก "ประวัติการใช้งาน":

*   **Persistent Alias (ฉายาถาวร):** User มี "ร่างอวตาร" 1 ตัว (เช่น *Sad Panda #882*) ที่ผูกกับบัญชีจริงถาวร เก็บใน DB เพื่อให้คนกด Follow ได้
*   **Ephemeral Activity (กิจกรรมชั่วคราว):** ประวัติการเข้าห้อง, ข้อความแชทในห้อง จะถูก **ลบทิ้งทุก 24 ชม.** (Auto-Wipe)
*   **One-way Follow:** การกดติดตามจะเป็นแบบทางเดียว (Follower เห็น Avatar แต่ Avatar ไม่รู้ว่าใครตาม) รักษาความเป็นส่วนตัว

### C. Safety Net & Emergency Handoff (ระบบความปลอดภัยชีวิต)
*   **Risk Scoring:** คำนวณคะแนน PHQ-9 ทันทีที่ส่งแบบประเมิน
*   **Automatic Trigger:**
    *   คะแนน > 15 (Moderate): แจ้งเตือนหมอเจ้าของไข้
    *   คะแนน > 19 (Severe): API ส่ง Flag `emergency_action: true` กลับไปที่แอป -> แอปจะเปลี่ยนหน้าจอเป็นปุ่ม **"โทรหา 1669 / สายด่วน"** ทันที

### D. Client-side DLP (ระบบป้องกันข้อมูลรั่วไหล)
กรองข้อมูลส่วนตัว **ก่อน** ส่งออกจากเครื่อง (Pre-transmission Filter) เพื่อความปลอดภัยสูงสุดใน E2EE Chat:

*   **Regex Filter:** ดักจับแพทเทิร์น เบอร์โทร (08x...), Line ID, Email
*   **Action:**
    *   **Soft Block:** ขึ้นเตือน "ห้ามส่งข้อมูลส่วนตัว"
    *   **Hard Masking:** ถ้ายืนยันจะส่ง ระบบจะเปลี่ยนข้อความเป็น `********`

### E. Moderation & Reporting (ระบบดูแลความสงบเรียบร้อย)
จัดการ User ที่มีพฤติกรรมไม่เหมาะสม (Toxic User) โดยอัตโนมัติ:
*   **User Report API:** ปุ่มกดรายงาน (Reason: ก่อกวน, คุกคาม, โฆษณา)
*   **Auto-Mute Logic:** หาก Ghost Profile โดน Report เกิน X ครั้งในเวลาสั้นๆ (Burst Rate) -> ระบบจะ **Mute อัตโนมัติ (ชั่วคราว)** ทันที เพื่อระงับเหตุระหว่างรอ Admin ตรวจสอบ

---

## 3. Database Schema (โครงสร้างข้อมูล)

เราออกแบบ Database โดยยึดหลัก **Zero-Knowledge Architecture** (Server รู้ให้น้อยที่สุด)

### `profiles` (Users)
แยก Role ชัดเจน และเก็บข้อมูลยืนยันตัวตนแบบ Hashed
*   `id`: UUID (PK)
*   `role`: 'patient' | 'doctor' | 'admin'
*   `license_id`: String (เฉพาะหมอ - เอาไว้ Verify)
*   `is_online`: Boolean (Sync จาก Redis)

### `appointment_slots` (ตารางงานหมอ)
หัวใจของระบบ Telemed
*   `id`: UUID
*   `doctor_id`: UUID
*   `start_time`, `end_time`: Timestamp
*   `status`: 'AVAILABLE' | 'RESERVED' | 'CONFIRMED'
*   `reserved_at`: Timestamp (ใช้สำหรับ Cron Job กวาดล้างการจองที่ค้าง)

### `opd_notes` (OPD Card) & `personal_notes` (Diary)
แยกที่เก็บชัดเจนเพื่อความเป็นส่วนตัว
*   **OPD Notes:** หมอเขียน / เชื่อมกับ Appointment ID / **E2EE Encrypted** (หมออ่านได้คนเดียว/ทีมรักษา)
*   **Personal Notes:** คนไข้เขียน / เชื่อมกับ Patient ID / **Private Encrypted** (คนไข้อ่านได้คนเดียว หมอไม่เห็น)

### `ghost_profiles`
*   `id`: UUID
*   `display_name`: "Random Adjective + Animal + Number"
*   `followers_count`: Integer

### `consent_logs` (PDPA Legal Logs)
เก็บหลักฐานทางกฎหมายว่า User ยอมรับเงื่อนไขแล้ว
*   `id`: UUID
*   `user_id`: UUID
*   `term_version`: String (เช่น '1.0', '1.2' - เผื่ออนาคตเปลี่ยนกฎ)
*   `accepted_at`: Timestamp
*   `ip_address`: String (Optional - เก็บเพื่อยืนยันตัวตน)

---

## 4. Back-office & Admin Tools (ระบบหลังบ้าน)

เราใช้ **Django Admin** ปรับแต่งพิเศษเพื่อลดเวลา Dev Frontend ใหม่:

### Doctor Verification
*   **UI:** แสดงรูปภาพ "ใบประกอบวิชาชีพ" และข้อมูลแพทยสภา
*   **Action:** ปุ่ม **[Approve]** / **[Reject]**
*   **Logic:** เมื่อกด Approve -> เปลี่ยน Role เป็น Doctor -> ส่ง Email แจ้งผล

### Refund & Cancellation
*   **Action:** ปุ่ม **[Cancel Appointment]** ในหน้ารายละเอียดนัดหมาย
*   **Logic:** คืนสิทธิ์ (Slot Status -> Available) และ Trigger ระบบคืนเงิน (Manual/Gateway)

---

## 5. Security & Privacy Strategy (ยุทธศาสตร์ความปลอดภัย)

### A. Encryption Strategy
1.  **Transport Layer:** HTTPS/WSS 100% (บังคับ SSL)
2.  **Storage Layer (At Rest):** Database Encrypted (Supabase Standard)
3.  **Application Layer (E2EE):**
    *   ข้อความแชท และ OPD Note จะถูกเข้ารหัสด้วย **Review Key** ที่ฝั่ง Client ก่อนส่ง
    *   Server จะเห็นเป็นก้อน Text มั่วๆ (`x8s#9v...`)

### B. Auto-Cleanup (ระบบเทศบาลเก็บขยะ)
ใช้ **Django-Q** รัน Cron Job ทุกเที่ยงคืน:
1.  **Privacy Wipe:** ลบ Chat Log ที่เก่าเกิน 90 วัน
2.  **Activity Wipe:** ลบประวัติการเข้าห้อง Clubhouse ที่เก่าเกิน 24 ชม.
3.  **Booking Sweep:** ปลดล็อก Slot ที่สถานะ `RESERVED` ค้างเกิน 15 นาที (กันเหนียว เผื่อ Redis หลุด)

---

## 5. Maintenance & Reliability

### Force Update & Config Logic
ทุกครั้งที่เปิดแอป แอปจะเรียก API `/config/init`:
*   **Version Check:** ถ้าแอปเวอร์ชันเก่ากว่า `min_supported_version` -> บังคับอัปเดต (กัน Bug/Security Fix ไม่ทำงาน)
*   **Maintenance Mode:** ถ้า Server ปิดปรับปรุง -> แอปจะขึ้นหน้า "ปิดปรับปรุงชั่วคราว" แทนการหมุนติ้วๆ

### Internet Disconnect Handling
ใช้ **LiveKit Webhook** เพื่อจับตาดู Connection:
*   ถ้าหมอหลุด (`participant_disconnected`) -> Backend รับรู้ -> ส่ง Push Noti บอกคนไข้ว่า "หมอกำลังเชื่อมต่อใหม่..."
*   ช่วยลดความตกใจของคนไข้เวลาจอดับ

---

---

## 6. Infrastructure Setup (Docker Hybrid)

เพื่อให้ง่ายต่อการทดสอบและ Deploy เราจะใช้ **Docker Compose**

### `docker-compose.yml`
```yaml
version: '3.8'

services:
  # 1. Database (PostgreSQL)
  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=vivaclub
      - POSTGRES_PASSWORD=secret
    volumes:
      - pg_data:/var/lib/postgresql/data

  # 2. Redis (Cache/Queue)
  redis:
    image: redis:alpine

  # 3. Backend (Django)
  backend:
    build: .
    command: daphne -b 0.0.0.0 -p 8000 config.asgi:application
    volumes:
      - .:/app
    depends_on:
      - db
      - redis
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.dev
      - DATABASE_URL=postgres://postgres:secret@db:5432/vivaclub
      - REDIS_URL=redis://redis:6379/1

  # 4. Cron Jobs (Django-Q)
  qcluster:
    build: .
    command: python manage.py qcluster
    depends_on:
      - backend
```

---

## 7. API Specification Summary (Endpoint Contract)

สรุป API สำคัญที่ Frontend ต้องเรียกใช้:

### Auth
*   `POST /api/auth/login` (Login with Phone/Password)
*   `POST /api/auth/register` (Register)
*   `GET /api/auth/me` (Get My Profile)

### Config & Update
*   `GET /api/config/init` (Check Version, Maintenance Mode)

### Doctors & Booking
*   `GET /api/doctors` (List Doctors)
*   `GET /api/doctors/:id/slots` (Get Available Slots)
*   `POST /api/bookings/reserve` (Lock Slot - 5 min TTL)
*   `POST /api/bookings/confirm` (Pay & Finalize)

### Clubhouse
*   `GET /api/rooms` (List Active Rooms)
*   `POST /api/rooms` (Create Room)
*   `POST /api/ghosts/follow` (Follow Alias)

นี่คือแผนแม่บทที่รวม Security, Privacy และ UX/UI Logic เข้าด้วยกัน เพื่อให้เป็น App สุขภาพจิตที่ "ไว้ใจได้" ที่สุดครับ
