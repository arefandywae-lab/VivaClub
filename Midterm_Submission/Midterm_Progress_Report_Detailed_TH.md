# รายงานความคืบหน้าโครงงาน (Midterm Progress Report) ชบับละเอียด (Detailed Technical Report)
**ชื่อโครงงาน:** VivaClub (แพลตฟอร์มโซเชียลเสียงเรียลไทม์ และ ระบบปรึกษาแพทย์ออนไลน์)

**รายชื่อสมาชิก:**
1. [ชื่อ-นามสกุล] - รหัสนักศึกษา: [รหัสนักศึกษา]
2. [ชื่อ-นามสกุล] - รหัสนักศึกษา: [รหัสนักศึกษา]

---

## 1. Tech Stack (สถาปัตยกรรมเทคโนโลยีที่ใช้)
ระบบถูกประดิษฐ์ขึ้นในรูปแบบ **Decoupled Architecture** (แยกกันระหว่างบ้านกับหน้าบ้านอย่างชัดเจน) โดยประกอบไปด้วย:

### 1.1 Frontend (แอปพลิเคชันมือถือ)
- **Framework:** Flutter (Dart) ใช้พัฒนาเป็นแอปพลิเคชันที่สามารถทำงานได้ทั้ง iOS และ Android จาก Codebase เดียวกัน
- **State Management:** `flutter_bloc` (BLoC Pattern) ช่วยคุมลอจิกของการไหลเวียนข้อมูล (Data flow) ไม่ให้ปนกับ UI
- **Network / API Client:** `Dio` สำหรับใช้เป็น HTTP Client หลักในการพูดคุยกับ Backend (รองรับ Interceptors เพื่อขอ Refresh Token อัตโนมัติ)
- **Real-time Engine Client:** `livekit_client` สำหรับทำ WebRTC connections ในการสตรีมเสียงความหน่วงต่ำ
- **Secure Storage:** `flutter_secure_storage` สำหรับเก็บความลับ (Tokens) ในเครื่องโทรศัพท์

### 1.2 Backend (เซิร์ฟเวอร์ และ API)
- **Framework:** Django และ Django REST Framework (DRF) พัฒนาด้วยอักษร Python
- **Authentication:** `Djoser` ร่วมกับ `djangorestframework-simplejwt` ทำระบบ Login แบบ Stateless-token
- **Database ORM:** กรองข้อมูลผ่าน Django ORM
- **WebRTC Controller:** เชื่อมต่อ LiveKit Server API สำหรับจัดการห้องประชุมเสียงและมอบ Access Token (Twirp protocol)

### 1.3 Infrastructure, Cloud และ Deployment
- **Cloud Provider (Main Backend):** ปัจจุบันใช้บริกการ **Railway.app** (PaaS) ในการ Host ตัวโค้ด Backend ทำงานร่วมกับ Docker อย่างอัตโนมัติ
- **Database Server:** **PostgreSQL** บน Railway
- **Audio/Media Server:** ใช้ **LiveKit Cloud** (หรือ Self-hosted LiveKit) ทำหน้าที่เป็น WebRTC Signaling Server และ SFU (Selective Forwarding Unit)
- **Mobile Deployment Environment:** รันจริงผ่านแอปเปิลออปชั่น (Apple Developer Provisioning Profile) บน iPhones เพื่อการทดสอบสิทธิ์ ฮาร์ดแวร์ ไมโครโฟน

---

## 2. ฐานข้อมูล (Database Schema)
ตอนนี้ Backend มีการเก็บข้อมูลลง Database (PostgreSQL) ดังนี้:

### ตาราง `User` (Custom User Model ของ Django)
- `id`: (UUID หรือ AutoField) Primary Key ของยูเซอร์
- `username`: ชื่ออ้างอิงของแต่ละระบบ
- `email`: อีเมลสำหรับ Login และแจ้งข่าว (Unique Field)
- `password`: รหัสผ่าน (เก็บเป็น Hash ไม่สามารถอ่านได้)
- `is_active`, `is_staff`: ตัวระบุว่าบัญชียังใช้งานได้ หรือเป็นแอดมินไหม

### ตาราง `GhostProfile` (ข้อมูลผู้ใช้ที่เชื่อมกับ User เป็น 1-to-1)
- `user`: Foreign Key ไปยังตาราง User
- `display_name`: ชื่อโปรไฟล์ที่จะโชว์ให้คนอื่นเห็น
- `avatar_path`: เส้นทางการเก็บรูปโปรไฟล์
- `role`: เก็บประเภทบัญชี เช่น `patient` (คนไข้ทั่วไป/ผู้ฟัง), `doctor` (หมอ/ผู้เชี่ยวชาญ), `admin`
- `bio`: ข้อความแนะนำตัวย่อๆ ของหมอ

### ตาราง `Room` (ห้องข้อความเสียง/ระบบคลับเฮาส์)
- `id`: Primary Key (UUID) เพื่อไม่ให้คาดเดาง่าย
- `title`: หัวข้อ/ชื่อห้องสนทนา
- `description`: คำอธิบายห้อง
- `host`: Foreign Key กลับไปหา `GhostProfile` ของคนที่สร้างห้อง
- `status`: สถานะของห้อง (`active` หรือ `ended`)
- `created_at` / `ended_at`: Timestamp วัน-เวลา ระบบจดบันทึกไว้

---

## 3. ระบบความปลอดภัยและการเข้ารหัสลับ (Encryption & Security Methods)

เพื่อให้สอดคล้องกับมาตรฐานอุตสาหกรรม (Industry standards) ซอร์สโค้ดของ VivaClub ได้วางมาตรการด้าน Security ไว้ 4 ระดับ:

1. **Password Encryption (At Rest):** 
   - รหัสผ่านทุกชนิดจะถูกประทับตรารหัส (Hashes) ก่อนเซฟลง PostgreSQL เสมอด้วยแกนหลัก **PBKDF2 (Password-Based Key Derivation Function 2)** พร้อมกลไกผสมเกลือ (HMAC-SHA256) ป้องกันการนำตารางข้อมูลไปเดารหัสผ่านกลับมา
2. **Access Token (In Memory):** 
   - ระบบ Login แจกจ่ายกุญแจแบบ **JSON Web Token (JWT)**
   - Token จะมีอายุตามเวลาที่กำหนด (เช่น 1 วัน/15 นาที) และถูก Signature โดย Secret Key ของเซิร์ฟเวอร์ที่อยู่ในไฟล์ `.env` ผู้ใช้ไม่สามารถแปลงสิทธิ์(Role)ใน Payload ฝั่งตัวเองได้
3. **Data Transport Encryption (In Transit):** 
   - ทุกๆ Request สู่ API จะวิ่งผ่านโปรโตคอล **HTTPS (TLS 1.2/1.3)** เพื่อซ่อนข้อมูล (Payload data)
   - ข้อมูลเสียง (Voice audio packets) มีการเข้ารหัสตั้งแต่ต้นทางยันปลายทาง (End-to-End) ด้วยโปรโตคอล **SRTP (Secure Real-time Transport Protocol)** จัดการโดย LiveKit WebRTC ป้องกันนักดักจับแพคเก็ต (Packet Sniffers)
4. **Client Secret Storage (Mobile):** 
   - ใช้หลักการจัดเก็บ Token ในบริเวณที่ลึกที่สุดของ OS โดยการใช้ไลบรารี `flutter_secure_storage` 
   - iOS: บันทึกเข้าฐานระบบรักษาความปลอดภัย **Apple Keychain**
   - Android: บันทึกเข้า **Android Keystore (Encrypted Shared Preferences)**

---

## 4. รายชื่อเส้นทาง API ทั้งหมดที่มีการใช้งาน (Backend API Routes Listing)

ได้ดำเนินการพัฒนาและผูกเชื่อมการทำงานกับ Mobile App เรียบร้อยในหัวข้อเกี่ยวกับ Authen และ ห้องสด (Live Audio Rooms) ดังนี้:

### กลุ่ม Authentication APIs (จัดการบัญชีผู้ใช้งาน)
1. **`POST /api/auth/register/`**
   - **หน้าที่:** รับ Email, Username, Password เข้ามา สร้างบัญชีและแฮชรหัสผ่านลง DB
2. **`POST /api/auth/login/`**
   - **หน้าที่:** รับ Email/Password ส่งกุญแจ Access Token สิทธิ์เบื้องหลังสำหรับใช้กับ API อื่น
3. **`GET /api/auth/profile/`**
   - **หน้าที่:** สำหรับเข้าเช็กโปรไฟล์ และคืนค่า Username, Role (เช่น สิทธิความเป็นหมอ) ให้หน้าจอมือถือโชว์ได้ถูกหน้า

### กลุ่ม Community Rooms APIs (จัดการระบบพูดคุยเสียง)
4. **`GET /api/community/rooms/`**
   - **หน้าที่:** ดึงรายการห้องเสียง (List) ที่มีสถานะว่า `active` ทั้งหมดให้ผู้ใช้เลือกเข้าฟัง
5. **`POST /api/community/rooms/`**
   - **หน้าที่:** เอา Payload (Title) เข้ามา สร้างห้องบน DB อัตโนมัติและมอบสถานะว่าตนเป็นโฮสต์ (Host)
6. **`POST /api/community/rooms/<room_id>/join/`**
   - **หน้าที่หลักมาก (Core Architecture):** เมื่อแอปขอ join จะทำการให้ Django วิ่งไปเรียกเซอร์วิส **LiveKit Server Cloud** เพื่อขอรับ **Access Token (WebRTC Signal)** แล้วโยนให้มือถือ เครื่องลูกก็จะใช้รับสัญญาณเสียงได้เลย โดยแยกประเภท (Speaker/Listener)
7. **`POST /api/community/rooms/<room_id>/leave/`**
   - **หน้าที่:** ระบุการออกจากห้องผ่าน Database (แอปต้องส่งออก WebRTC เองที่เครื่องด้วย)
8. **`POST /api/community/rooms/<room_id>/invite/`**
   - **หน้าที่:** ผู้ที่เป็นโฮสต์ขอส่งออปชั่นดึง Listener (ผู้ฟังธรรมดา) กลับมารับสิทธิ์เป็น Speaker เปลี่ยนโหมด Permission บน LiveKit อย่างเรียลไทม์

### กลุ่ม Moderation API (ระบบจัดการผู้พูด และเตะผู้เล่น - เพิ่งพัฒนาติดตั้งเสร็จ)
9. **`POST /api/community/rooms/<room_id>/mute-participant/`**
   - **หน้าที่:** โฮสต์ใช้ API ตัวนี้โยนคำสั่งระงับไมค์ (Mute) บังคับปิดสัญญาณเสียงโดยอ้างถึง `track_sid` และ `identity` ของคนในห้อง Backend จะส่งสัญญาณ API สั่งไปที่โปรโตคอลของ LiveKit ปิดซอร์สเสียงแบบทันที (Force Disable Audio)
10. **`POST /api/community/rooms/<room_id>/kick-participant/`**
   - **หน้าที่:** โฮสต์สั่งเตะ (Kick/Disconnect) อาชญากรป่วนห้อง Backend จะรีเควสต์ไปยัง LiveKit ให้ตัดการเชื่อมต่อ WebSocket และปิด Connection อัตโนมัติ


*(อัปเดตงาน Frontend เชิงกลไก: ปุ่มหน้า Home Dashboard และ LiveRoom มีการเพิ่มปุ่ม Tap-and-hold เรียก Moderation Dialogue ไว้แล้ว พร้อมใช้กลไก LiveKit Metadata ซิงโครไนซ์สถานะ "การยกมือ - Hand Raise" ระหว่างสมาร์ทโฟนฝั่งผู้ฟังและโฮสต์)*

---

## 5. การทดสอบและการครอบคลุมของโค้ด (Testing & Test Coverage)

เพื่อให้สถาปัตยกรรมทำงานได้อย่างมีเสถียรภาพที่สุด ทีมได้ดำเนินการเขียน **Automated Test Scripts** เพื่อจำลองพฤติกรรมผู้ใช้งานจำนวนมาก และลดข้อผิดพลาดก่อนนำขึ้นโปรดักชัน (Production Deployment):

### 5.1 Backend API Unit & Integration Tests (Django)
มีการจำลองส่งคำขอ (Mock Requests) และยิงทดสอบ API ผ่าน Script อย่างต่อเนื่อง (เช่น `test_api.sh`, `test_clubhouse.py`)
- **Authentication Flow:** รันสคริปต์สุ่มสร้าง User ใหม่หลายรูปแบบเพื่อทดสอบการ Hash Password และการป้องกัน User ขยะ
- **Room Management Load Test:** ทดสอบสร้างห้องทีละหลายสิบห้องพร้อมกัน เพื่อเช็กว่า Database Transaction ไม่เกิด Deadlock และเซิร์ฟเวอร์ตอบกลับรหัส `200 OK`

### 5.2 Real-time Engine Testing (WebSocket & LiveKit Integration)
นี่คือส่วนที่ทำ Test Coverage ลึกที่สุดเนื่องจากเป็น Core Feature:
- **WebRTC Handshake Validation:** เขียนโค้ด (Python/LiveKit Client ในสคริปต์ `test_invite_isolated.py` และ `test_interactions_connected.py`) จำลองสร้างบอท 1 ตัวเป็นโฮสต์ และบอทอีก 1 ตัวเป็นผู้ฟัง (Listener) เข้ามาต่อ WebSocket ชนกันในห้องเดียวกัน
- **State Consistency Coverage:** ตรวจสอบความถูกต้องของการกระจายข่าว (Event Broadcasting)
  - ทดสอบระบบ Hand Raise (ยกมือ) ว่าเมื่อ Listener ขอยกมือ Metadata ของห้องจะต้องอัปเดตไปถึงโฮสต์ **100% (Pass)**
  - เมื่อโฮสต์เตะ (Kick) หรือ ปิดไมค์ (Mute) บอทที่เป็น Listener จะต้องถูกบล็อกจาก Audio Track และถูกตัดออกจาก LiveKit ทันที (Test Passed and Confirmed via API code 200)

### 5.3 Frontend QA & Device Compatibility Tests
- ทดสอบการรันผ่าน Flutter UI จริง บน iOS Simulator และ **อุปกรณ์จริง (iPhone)** เพื่อตรวจสอบ Native Permissions (ไมโครโฟน) สิทธิ์ในการส่องทิศทางเสียง รวมถึงตรวจสอบ Memory Leaks ในกรณีถอดสายและใช้โหมด Release (`flutter run --release`) ซึ่งแอปปัจจุบันเสถียรและสามารถใช้งานต่อเนื่องได้โดยไม่มี Crash Log

---

## 6. แผนพัฒนาในโค้งสุดท้าย (Remaining Final Phase)

การทำงานในฝั่ง Backend, WebRTC Engine และ Flutter UI ลุล่วงเปรียบเทียบในหมวด "Audio Club Feature" แบบสมบูรณ์แล้ว งานถัดไปของทีม (Remaining Task) คือฝั่ง "Telemedicine/Monetization" เพื่อตอบโจทย์ธุรกิจแอปรวม (Business Logic Requirement):

1. **ระบบจองเวลาแพทย์ (Scheduled Consultations)**
   - API กลุ่ม `/api/bookings/slots/` (เพิ่มตาราง DB เพื่อเซฟกรอบเวลาคิวของหมอแต่ละท่าน)
   - หน้าจอ (Flutter) รูปแบบปฏิทิน และการล็อกห้อง Private คุยสองคนแบบจับเวลาถอยหลัง (Expired token handling ด้วย LiveKit)
2. **กระเป๋าเงิน และ การเปย์เหรียญสด (In-App Wallet & Subscriptions)**
   - สคีมา (Schema): `Wallet` (ยอดเงินปัจจุบัน) และ `Transaction` (ประวัติการเปย์ / เหรียญโอนให้โฮสต์)
   - Mocking Payment และเหรียญเปย์ขวัญกำลังใจเป็นแอนิเมชันขึ้นจอบน Flutter ที่ลดบารอมิเตอร์ (token deducing) หลังบ้านอย่างปลอดภัย
3. **ระบบแจ้งเตือนฉับไว (Push Notifications Backend)**
   - เชื่อมต่อโปรเจกต์กับ **Firebase Cloud Messaging (FCM)** ให้โทรศัพท์ดังเตือนแม้ปิดจอ กรณีหมอที่คุณตามกดเปิดห้องแล้ว ("Doctor [...] has started a room!") หรือเมื่อใกล้ถึงคิวปรึกษา
