# รายงานความคืบหน้าโครงงาน (Midterm Progress Technical Report)

**ชื่อโครงงาน:** VivaClub  
**คำอธิบาย:** แพลตฟอร์มโซเชียลเสียงเรียลไทม์ และ ระบบปรึกษาแพทย์ออนไลน์

**รายชื่อสมาชิก:**
- Arefandy Waeouseng — 6610625037
- Phuritat Lertkitpaisarn — 6610685049

---

## 1. Tech Stack (สถาปัตยกรรมเทคโนโลยีที่ใช้)

ระบบถูกพัฒนาขึ้นในรูปแบบ **Decoupled Architecture** (แยกกันระหว่างหลังบ้านกับหน้าบ้านอย่างชัดเจน) โดยประกอบไปด้วย:

### 1.1 Frontend Architecture (แอปพลิเคชันมือถือ)

| Library / Tool | บทบาท |
|---|---|
| **Flutter (Dart)** | Framework หลัก — รันได้ทั้ง iOS และ Android จาก Codebase เดียวกัน |
| **flutter_bloc (BLoC Pattern)** | State Management — คุม Data flow ไม่ให้ปนกับ UI |
| **Dio** | HTTP Client หลัก — พูดคุยกับ Backend รองรับ Interceptors เพื่อขอ Refresh Token อัตโนมัติ |
| **livekit_client** | Real-time Engine Client — จัดการ WebRTC connections สำหรับสตรีมเสียงความหน่วงต่ำ |
| **flutter_secure_storage** | Secure Storage — เก็บ Tokens ในเครื่องโทรศัพท์อย่างปลอดภัย |

### หลักการทำงานของ BLoC Pattern (Business Logic Component)

เพื่อแก้ปัญหา Code ยุ่งเหยิง (Spaghetti Code) และทำให้แอปพลิเคชันตอบสนองได้อย่างเสถียร (Zero Crash) จึงนำ BLoC Pattern มาเป็นสถาปัตยกรรมหลักในการแบ่งแยกหน้าที่ (Separation of Concerns):

- **UI Layer:** หน้าที่วาดหน้าจอ สร้างปุ่มกด คุมเฉพาะแอนิเมชัน ไม่มีการคำนวณใดๆ ปนอยู่เลย เมื่อผู้ใช้กดปุ่ม (เช่น กด Join Room) UI จะแค่ "พ่น Event" โยนทิ้งไว้ให้ BLoC นำไปจัดการ
- **BLoC Layer:** เฝ้ารอรับ Event จาก UI แล้วนำไปคำนวณ หรือสั่งให้ Repository ไปทำงานต่อ เมื่อทำงานเสร็จหรือพัง BLoC จะทำการเปลี่ยนสถานะ (State) แล้วสะท้อนกลับไปบอก UI (เช่น ส่ง `LoadingState` → `SuccessState` → ทริกเกอร์เปลี่ยนหน้าจอ)
- **Repository/Service Layer (ท่อลำเลียงข้อมูล):** เป็นกรรมกรของ BLoC ทำหน้าที่ติดต่อสื่อสารกับโลกภายนอกเพียงอย่างเดียว เช่น วิ่งผ่าน Dio ไปคุยกับ Django API, โอนถ่าย Token ไปหา LiveKit Server แล้วมัดรวมข้อมูลส่งคืนเป็น Object (Dart Model) แจกให้ BLoC

> **ข้อดีของโครงสร้าง 3 ชั้น:** แม้ในอนาคตทีมจะอยากเปลี่ยนดีไซน์ปุ่มกดใหม่ทั้งแอป หรือรื้อหน้าจอใหม่ ก็สามารถทำได้โดยที่โค้ดคำนวณหลังบ้านไม่พังเลย เพราะมันถูกตัดขาดจากกัน

```
UI Layer
  HomeScreen     AuthScreen     LiveRoomScreen
       ↓               ↓               ↓
              BLoC Pattern
  Auth Bloc      Room Bloc      LiveKit Bloc
       ↓               ↓               ↓
              Repository & Network
  AuthRepo       RoomRepo      LiveKitService
       ↓               ↓               ↓
  Dio API Client    Secure Storage    LiveKit WebRTC Server
       ↓
  Django REST API
```

---

### 1.2 Backend (เซิร์ฟเวอร์ และ API)

| Library / Tool | บทบาท |
|---|---|
| **Django + DRF** | Framework หลัก — พัฒนาด้วย Python รวบรวม Business Logic ทั้งหมด |
| **Djoser + simplejwt** | Authentication — ระบบ Login แบบ Stateless JWT Token |
| **Django ORM** | Database — กรองและจัดการข้อมูลผ่าน ORM |
| **LiveKit Server API** | WebRTC Controller — จัดการห้องเสียงและมอบ Access Token (Twirp protocol) |

---

### 1.3 Infrastructure, Cloud และ Deployment

| Component | Technology |
|---|---|
| **Cloud Provider (Main Backend)** | Railway.app (PaaS) — Host โค้ด Backend ทำงานร่วมกับ Docker อัตโนมัติ |
| **Database Server** | PostgreSQL บน Railway |
| **Audio/Media Server** | LiveKit Cloud (หรือ Self-hosted) — WebRTC Signaling Server และ SFU (Selective Forwarding Unit) |
| **Mobile Deployment** | Apple Developer Provisioning Profile บน iPhones เพื่อทดสอบสิทธิ์ฮาร์ดแวร์ไมโครโฟน |

---

## 2. ฐานข้อมูล (Database ER-Diagram & Schema)

Backend มีการเก็บข้อมูลลง Database (PostgreSQL) โดยมีการออกแบบและผูกความสัมพันธ์ดังนี้:

### ตาราง `user` (บัญชีแม่ข่าย)

| Type | Field | Constraint | Note |
|---|---|---|---|
| uuid | id | PK | Primary Key |
| string | username | | |
| string | email | | Unique constraint |
| string | password | | Hashed string (PBKDF2) |
| boolean | is_active | | |
| boolean | is_staff | | |

**→ has 1-to-1 connection ↓**

### ตาราง `ghost_profile` (อวตารและบทบาท)

| Type | Field | Constraint | Note |
|---|---|---|---|
| int | id | PK | |
| uuid | user_id | FK | 1-to-1 linkage |
| string | display_name | | Randomly generated or chosen |
| string | avatar_path | | Preset asset path |
| string | role | | `patient` \| `doctor` \| `admin` |
| text | bio | | Short bio for doctors |

**→ creates / hosts (1-to-Many) ↓**

### ตาราง `room` (ห้องสนทนาเสียง)

| Type | Field | Constraint | Note |
|---|---|---|---|
| uuid | id | PK | UUID4 |
| string | title | | |
| string | description | | |
| int | host_id | FK | Link to GhostProfile |
| string | status | | `active` \| `ended` |
| datetime | created_at | | |
| datetime | ended_at | | |

---

### กลไกความปลอดภัยในการสร้างโปรไฟล์ (Preset-Only Policy)

เพื่อแก้ปัญหาการคุกคามและการใช้รูปโป๊เปลือย (Sexual/Harassment Content):

- **อัลกอริทึมสุ่มชื่อ (Random Name Generator):** ประยุกต์ใช้คลังคำศัพท์ปลอดภัย (Safe Word Bank) โดยดึง Category A (คำคุณศัพท์ เช่น `Happy`, `Cosmic`) มาต่อกับ Category B (คำนาม เช่น `Panda`, `Ninja`) และเติมตัวเลขต่อท้ายเพื่อป้องกันการซ้ำ เช่น `Happy_Panda_99`
- **ระบบบังคับเลือกไอคอน (Preset Avatar Selection):** ปิดฟังก์ชันการ Upload รูปภาพจากอัลบั้มมือถือเด็ดขาดสำหรับผู้ใช้ทั่วไป (Patient/Listener) โดยบังคับให้ระบบสุ่มรูปจากคลังแอป (Asset Presets) ตอนสมัคร
  > **ข้อยกเว้น:** เฉพาะบัญชีที่ยืนยันเป็นแพทย์ (`role=doctor`) เท่านั้น ที่จะปลดล็อกให้ตั้งชื่อจริงและอัปโหลดรูปใบหน้าจริงได้ เพื่อความน่าเชื่อถือ

---

## 3. ระบบความปลอดภัยและการเข้ารหัสลับ (Encryption & Security Methods)

วางมาตรการด้าน Security ไว้ **4 ระดับ** เพื่อให้สอดคล้องกับมาตรฐานอุตสาหกรรม (Industry Standards):

### ระดับที่ 1 — Password Encryption (At Rest)

รหัสผ่านทุกชนิดจะถูกประทับตรารหัส (Hash) ก่อนเซฟลง PostgreSQL เสมอด้วยหลัก **PBKDF2** (Password-Based Key Derivation Function 2) พร้อมกลไกผสม **HMAC-SHA256**

เมื่อผู้ใช้กรอกรหัสผ่าน `123456` ระบบ (Django Auth) จะนำไปบวกค่า Random Salt และทำซ้ำจนได้ลายนิ้วมือดิจิทัลที่ถอดความหมายกลับไม่ได้:

```
pbkdf2_sha256$720000$RandomSaltData$HASHED_PASSWORD_DATA=
```

### ระดับที่ 2 — Access Token (In-Memory / Stateless Authentication)

ระบบ Login ทำงานแบบแจกจ่าย **Stateless JWT (JSON Web Token)** โดยไม่ต้องจดจำ Session ไว้ในฐานข้อมูล

- **Self-Destructing & Rotation:** Access Token มีอายุใช้งานสั้นเพียง **60 นาที** หากขโมย Token ระหว่างทางก็จะหมดอายุอย่างรวดเร็ว
- **Token Rotation:** ขณะที่ผู้ใช้ใช้งานแอป ตัวแอปจะใช้ Refresh Token แอบวิ่งไปสลับเอา Access Token ใบใหม่โดยอัตโนมัติ ทำให้ Login ไม่หลุด
- เมื่อ Token ครบอายุขัย ระบบ **Blacklist** ของเซิร์ฟเวอร์จะกำจัดทิ้งทันที

### ระดับที่ 3 — Data Transport Encryption (In-Transit)

- ทุกๆ Request สู่ REST API จะวิ่งผ่านโปรโตคอล **HTTPS (TLS 1.2/1.3)** เพื่อซ่อนข้อมูล (Payload data)
- เสียงสนทนาเข้ารหัสด้วย **SRTP (Secure Real-time Transport Protocol)** ผ่านกระบวนการ **DTLS-SRTP Handshake** ก่อนคุยทุกครั้ง หากมีการดักจับแพ็คเก็ต (Packet Sniffing) กลางทาง จะได้เพียง "ขยะดิจิทัล (Gibberish)" ที่ฟังไม่รู้เรื่อง

### ระดับที่ 4 — Client Secret Storage (Mobile / Hardware)

Token ในเครื่องมือถือถูกเซฟตี้ผ่านไลบรารี `flutter_secure_storage`:

| Platform | Storage Mechanism |
|---|---|
| iOS | Apple Keychain |
| Android | Android Keystore (Encrypted Shared Preferences) |

---

## 4. รายชื่อเส้นทาง API ทั้งหมด (Backend API Routes Listing)

### กลุ่ม Authentication APIs (จัดการบัญชีผู้ใช้งาน)

| Method | Endpoint | หน้าที่ |
|---|---|---|
| `POST` | `/api/auth/register/` | รับ Email, Username, Password สร้างบัญชีและแฮชรหัสผ่านลง DB |
| `POST` | `/api/auth/login/` | รับ Email/Password คืนค่า Access Token สำหรับใช้กับ API อื่น |
| `GET` | `/api/auth/profile/` | ดึงข้อมูลโปรไฟล์ คืนค่า Username, Role ให้หน้าจอมือถือแสดงผล |

### กลุ่ม Community Rooms APIs (จัดการระบบพูดคุยเสียง)

| Method | Endpoint | หน้าที่ |
|---|---|---|
| `GET` | `/api/community/rooms/` | ดึงรายการห้องเสียงที่มีสถานะ `active` ทั้งหมด |
| `POST` | `/api/community/rooms/` | รับ Payload (Title) สร้างห้องบน DB และมอบสถานะ Host |
| `POST` | `/api/community/rooms/<room_id>/join/` | ให้ Django วิ่งไปเรียก LiveKit Server เพื่อขอรับ Access Token (WebRTC Signal) แยกประเภท Speaker/Listener |
| `POST` | `/api/community/rooms/<room_id>/leave/` | ระบุการออกจากห้องผ่าน Database (แอปต้องส่งออก WebRTC เองที่เครื่องด้วย) |
| `POST` | `/api/community/rooms/<room_id>/invite/` | โฮสต์ดึง Listener ขึ้นมารับสิทธิ์เป็น Speaker เปลี่ยนโหมด Permission บน LiveKit แบบ Real-time |

### กลุ่ม Moderation APIs (ระบบจัดการผู้พูดและเตะผู้เล่น)

| Method | Endpoint | หน้าที่ |
|---|---|---|
| `POST` | `/api/community/rooms/<room_id>/mute-participant/` | โฮสต์ระงับไมค์ (Force Mute) โดยอ้างถึง `track_sid` และ `identity` — Backend ส่งสัญญาณไปที่ LiveKit Protocol ปิดแหล่งเสียงทันที |
| `POST` | `/api/community/rooms/<room_id>/kick-participant/` | โฮสต์สั่งเตะ (Kick/Disconnect) — Backend รีเควสต์ไปยัง LiveKit ให้ตัดการเชื่อมต่อ WebSocket และปิด Connection อัตโนมัติ |

---

## 5. อัลกอริทึมคะแนนความน่าเชื่อถือ (Trust Score Algorithm)

เพื่อป้องกันปัญหา **การกลั่นแกล้งกันด้วยการรุมรีพอร์ต (False Reporting)** ระบบถูกออกแบบให้มีกลไกคัดกรองพฤติกรรมผู้ใช้ด้วยมาตรฐาน **Weighted Voting (การโหวตแบบให้น้ำหนัก)**:

### ลำดับตรรกะ

1. **Base Score (คะแนนตั้งต้น):** ผู้ใช้ทุกคนเริ่มที่คะแนน **100 แต้ม** การกระทำหลังจากนี้จะกำหนดน้ำหนักของคำพูด (Report Power) ของตนเอง

2. **Positive Weight (การได้คะแนนเพิ่ม):** ถ้านาย A กด Report แล้วแอดมินตรวจสอบว่า "ผิดจริง"
   - นาย A จะได้ Trust Score เพิ่ม (เช่น **+10**)
   - ผลลัพธ์: เสียงและคำรีพอร์ตของนาย A ในครั้งถัดๆ ไปจะมีน้ำหนักมากกว่าคนปกติ

3. **Negative Weight (บทลงโทษจากการกลั่นแกล้ง):** ถ้านาย B เกณฑ์เพื่อนมารุม Report มั่วๆ แล้วแอดมินตรวจสอบพบว่า "ไม่ผิด (False Report)"
   - นาย B และแก๊งค์เพื่อน จะโดนหัก Trust Score ทิ้งทันที (เช่น **-20 ถึง -50**)
   - ผลลัพธ์: คำขอ Report ครั้งถัดไปของนาย B จะถูกระบบโยนลงถังขยะอัตโนมัติ (Spam Filter) แม้จะกดมาพันครั้งก็ไม่มีผล

4. **Auto-Ban Threshold (ศาลเตี้ยอัตโนมัติ):** ระบบจะรวม (Sum) คะแนน Trust Score ของทุกคนที่กด Report บุคคลเป้าหมาย หากผลรวมทะลุ Threshold (เช่น **> 500 แต้ม**) ระบบจะทำการ **Auto-Kick** ทันทีข้ามหน้าแอดมินมนุษย์ เพื่อยุติความวุ่นวายในห้องแบบ Real-time

5. **Promotion & Privileges (สิทธิประโยชน์แบบออโต้):** หากผู้ใช้มี Trust Score สะสมเกิน **180 แต้ม** ประวัติขาวสะอาด ระบบจะรัน Script เลื่อนขั้นให้เป็น **Community Moderator (ผู้คุมกฎอาสาสมัคร)** ผู้คุมกฎจะมีปุ่ม "Mute/Kick อัตโนมัติในห้องคนอื่น" โดยไม่ต้องรอโหวตให้เสียเวลา

---

## 6. การทดสอบและการครอบคลุมของโค้ด (Testing & Test Coverage)

### 6.1 Backend API Unit & Integration Tests (Django)

มีการจำลองส่งคำขอ (Mock Requests) และยิงทดสอบ API ผ่าน Script อย่างต่อเนื่อง (เช่น `test_api.sh`, `test_clubhouse.py`)

- **Authentication Flow:** รันสคริปต์สุ่มสร้าง User ใหม่หลายรูปแบบเพื่อทดสอบการ Hash Password และการป้องกัน User ขยะ
- **Room Management Load Test:** ทดสอบสร้างห้องทีละหลายสิบห้องพร้อมกัน เพื่อเช็กว่า Database Transaction ไม่เกิด Deadlock และเซิร์ฟเวอร์ตอบกลับรหัส `200 OK`

### 6.2 Real-time Engine Testing (WebSocket & LiveKit Integration)

ใช้ Script `test_invite_isolated.py` และ `test_interactions_connected.py` จำลองสร้าง:

- **Bot 1:** เป็นโฮสต์
- **Bot 2:** เป็นผู้ฟัง (Listener) เข้ามาต่อ WebSocket ชนกันในห้องเดียวกัน

**State Consistency Coverage ที่ทดสอบ:**

| Test Case | ผลลัพธ์ |
|---|---|
| Listener ยกมือ (Hand Raise) — Metadata ของห้องต้องอัปเดตไปถึงโฮสต์ | ✅ Pass (100%) |
| โฮสต์เตะ (Kick) Bot Listener — ต้องถูกตัดออกจาก LiveKit ทันที | ✅ Test Passed (API code 200) |
| โฮสต์ปิดไมค์ (Mute) Bot Listener — ต้องถูกบล็อกจาก Audio Track ทันที | ✅ Test Passed (API code 200) |

### 6.3 Frontend QA & Device Compatibility Tests

ทดสอบการรันผ่าน Flutter UI จริงบน:
- iOS Simulator
- อุปกรณ์จริง (iPhone) — ตรวจสอบ Native Permissions (ไมโครโฟน) และทิศทางเสียง
- ทดสอบ Memory Leaks ในโหมด Release (`flutter run --release`)

> **สรุป:** แอปปัจจุบันเสถียรและสามารถใช้งานต่อเนื่องได้โดยไม่มี Crash Log

---

## 7. แผนพัฒนาในเฟสถัดไป

การทำงานในฝั่ง Backend, WebRTC Engine และ Flutter UI ในหมวด **"Audio Club Feature"** สมบูรณ์แล้ว งานถัดไป (Remaining Tasks) คือฝั่ง **"Telemedicine / Monetization"**

### งานที่เหลืออยู่

1. **ระบบจองเวลาแพทย์ (Scheduled Consultations)**
   - API กลุ่ม `/api/bookings/slots/` — เพิ่มตาราง DB เพื่อเซฟกรอบเวลาคิวของหมอแต่ละท่าน
   - หน้าจอ (Flutter) รูปแบบปฏิทิน และการล็อกห้อง Private คุยสองคนแบบจับเวลาถอยหลัง (Expired token handling ด้วย LiveKit)

2. **ระบบแจ้งเตือนฉับไว (Push Notifications Backend)**
   - เชื่อมต่อโปรเจกต์กับ **Firebase Cloud Messaging (FCM)**
   - โทรศัพท์ดังเตือนแม้ปิดจอ กรณี:
     - หมอที่คุณตามกดเปิดห้องแล้ว ("Doctor [...] has started a room!")
     - เมื่อใกล้ถึงคิวปรึกษา
