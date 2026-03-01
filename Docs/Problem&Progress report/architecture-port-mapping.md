# System Architecture & Port Mapping
**VivaClub Infrastructure Documentation**

เอกสารอธิบายการทำงานร่วมกันของ Service ต่างๆ, การใช้ Port, การเชื่อมต่อผ่าน API / WebSocket / Redis อย่างละเอียด

---

## 🏗 ภาพรวมของสถาปัตยกรรม (Architecture Overview)

VivaClub ใช้ **Microservices-oriented architecture** เล็กๆ เพื่อแบ่งการรับส่งข้อมูลตามหน้าที่ โดยมีใจกลางหลักคือ **Django (Backend)**, **LiveKit (WebRTC Audio/Video)**, และ **Redis (Pub/Sub & Channel Layers)**

### ทำไมถึงเลือกใช้ Stack เหล่านี้?
1. **LiveKit:** ตัวเลือกอันดับ 1 สำหรับ WebRTC แบบสเกลได้ ถูกออกแบบมาสำหรับทำระบบ Clubhouse / Spaces โดยเฉพาะ จัดการเรื่อง Latency, Mute/Unmute, และการดรอปคุณภาพเน็ตให้ผู้ใช้ได้ดีมาก
2. **Redis:** จำเป็นมากในการทำ **Django Channels (WebSockets)** เนื่องจาก Django เป็น Synchronous HTTP แต่การทำห้องแชท หรือ Real-time Notification ต้องการ WebSocket ซึ่ง Redis จะทำหน้าที่เป็น Message Broker คอยกระจายข้อความจาก Server ไปให้ Client ที่ต่อ WebSocket อยู่
3. **Caddy:** Reverse Proxy สมัยใหม่ ใช้งานง่ายกว่า NGINX มาก และจุดเด่นสูงสุดคือ **ทำ HTTPS / SSL (Let's Encrypt) ให้อัตโนมัติ 100%** เพียงแค่ชี้ Domain และตั้งค่า 2-3 บรรทัด
4. **Django + Daphne:** เร็วในการพัฒนา API ส่วน Daphne ทำหน้าที่เป็น ASGI Server เพื่อรองรับ Long-polling / WebSockets

---

## 🔌 Port Mapping & Network Flow

นี่คือแผนผัง Port ที่เปิดใช้งานใน VPS ของ Docker Compose และหน้าที่ของมัน:

### 🌐 1. Caddy (Reverse Proxy / Load Balancer)
- **Ports:** `80` (HTTP), `443` (HTTPS)
- **หน้าที่:** หน้าด่านแรกของระบบทั้งหมด รับ Request จากภายนอก ทำ HTTPS ให้ และจัดเส้นทาง (Route) ส่งให้ Service อื่นๆ ด้านหลัง
- **Routing Rules:**
  - `https://vivaclubs.site/api/*` ➡️ ส่งต่อไปหา **Backend (Django) Port 8000**
  - `https://vivaclubs.site/ws/*` ➡️ ส่งต่อไปหา **Backend (Daphne) Port 8000** (อัปเกรดเป็น WebSocket)
  - `https://admin.vivaclubs.site` ➡️ ส่งต่อไปหา **Next.js Admin Dashboard Port 3000**

### 🧠 2. Backend (Django REST Framework + Daphne)
- **Internal Port:** `8000`
- **หน้าที่:** รับฝากข้อมูล DB, ระบบสมาชิก, ยืนยัน Authentication (JWT), โลจิกของห้องต่างๆ ตัวกลางส่ง Webhook 
- **การส่ง-รับข้อมูล:** 
  - **รับ API Request (HTTP):** GET/POST เพื่อสร้างห้อง, ยิงคำสั่ง Kick/Mute ส่ง LiveKit Token กลับไปที่แอป
  - **ส่ง (LiveKit SDK):** ใช้ Python SDK ยิง API ไปบอก LiveKit ว่า "เปลี่ยนสถานะ Mute", "ลบ Participant" หรือ "อัปเดต Metadata ของผู้เล่น"
  - **รับ (LiveKit Webhooks):** LiveKit จะยิง POST กลับมาที่พอร์ตนี้ เช่น แจ้งว่ามีคนเข้าร่วมห้อง (`participant_joined`) เพื่อบวกเลข Listener นับคนเข้าฟังใน Database

### 🗄️ 3. PostgreSQL (Database)
- **Internal Port:** `5432`
- **หน้าที่:** เก็บข้อมูลถาวรทั้งหมด (Users, Rooms, Settings, Reports, Followings)

### 🏎️ 4. Redis (Message Broker / Channel Layer)
- **Internal Port:** `6379`
- **การรับส่ง:**
  - ไม่ได้รับ Request โดยตรงจากภายนอก
  - เมื่อ Backend (Django) ต้องการส่งข้อความผ่าน WebSocket (เช่น มีแจ้งเตือน) Django จะส่งข้อมูลมาทิ้งไว้ที่ Redis
  - Daphne ที่ฝังอยู่ใน Backend จะคอยดึงข้อมูลจาก Redis และ Push ออกไปหา Flutter (Client) ทันที
  - Bot Service เชื่อมต่อ Redis เพื่อรับ Queue สั่งการว่าต้องทำ Action อะไร

### 🎙️ 5. LiveKit Server (WebRTC Engine)
- **Ports:** 
  - `7880` (HTTP, WebSockets) - API ควบคุม และ WebSocket Signaling สำหรับให้แอป Flutter ต่อเข้ามา
  - `7881` (TCP/UDP) - WHIP (WebRTC HTTP Ingestion Protocol - ไม่ค่อยได้ใช้ในแอปเรา)
  - `7882` (TCP) - WebRTC (RTC Streaming Payload - สายเสียงหรือวิดีโอถูกสตรีมผ่านรูนี้)
  - `7885` (UDP) - TURN Server สำหรับเจาะ NAT กรณีเน็ตบริษัทบล็อก
- **การรับส่ง:**
  - รับ Signaling จาก Flutter และจ่ายเส้นทาง Stream เสียงระหว่างผู้ใช้แบบ P2P หรือ SFU
  - รับ REST Command จาก Django (เช่น สั่งเตะ, จัดการ Metadata)

### 🤖 6. Next.js Admin Dashboard
- **Internal Port:** `3000`
- **หน้าที่:** หน้าเว็บควบคุมแอปพลิเคชันสำหรับ Admin แสดสถิติ แบนยูสเซอร์ เมื่อกดหน้าเว็บ Client (Browser) จะยิง API กลับไปที่โดเมนหลัก (`/api/...`) ซึ่งทะลุเข้า Caddy ➡️ Django

---

## 🔄 ตัวอย่าง Lifecycle ของการส่งข้อมูล (Flow)

### 1. เข้าสู่ห้อง (Join Room Flow)
1. **Flutter** ส่ง `POST /api/community/rooms/<id>/join` ➡️ **Caddy** ➡️ **Django**
2. **Django** ค้นหาห้อง, เช็คสิทธิ์, สร้าง LiveKit JWT Token พ่วง Metadata (role, ghost_id, host_status)
3. **Django** คืน Token ให้ Flutter
4. **Flutter** เอา Token ไปต่อ WebSocket Signal ที่ **LiveKit (Port 7880)**
5. **LiveKit** เชื่อมต่อสำเร็จ เปิดท่อ **Port 7882** ส่งสัญญาณเสียงกลับมาให้แอป
6. **LiveKit** ยิง Webhook (HTTP POST) กลับไปที่ **Django (Port 8000)** ว่า `participant_joined`
7. **Django** บันทึกว่า +1 Listener count 

### 2. อัปเดตการเลื่อนคนขึ้น Speaker (Drag-to-Invite / Kick Flow)
1. โฮสต์บนแอป **Flutter** ลากยูสเซอร์ไปหย่อน → ยิง `POST /api/community/rooms/<id>/invite/` ส่ง `identity` ของเป้าหมายไป ➡️ **Django**
2. **Django** ตรวจสอบว่า host มีสิทธิ์จริง จากนั้นใช้ `livekit-api` ยิงอัปเดตผ่าน HTTP ➡️ หาเครื่อง **LiveKit Server (Port 7880)** 
3. ข้อมูลที่ส่งคือคำสั่ง **UpdateParticipant**: 
   - `can_publish: true`
   - `metadata: {"speaker": true, "handRaised": false}`
4. **LiveKit** รับคำสั่ง นำไปกระจายบอก Client ทุกคนในห้องผ่าน Signaling WebSocket
5. เครื่องเป้าหมายบนแอป **Flutter** ได้รับ Event `metadata_changed` และสิทธิ์ใหม่ → เปิดไมค์ได้, เด้งขึ้นไปอยู่ห้องบนทันที

### 3. แจ้งเตือนแบบ Real-time นอกห้อง (WebSocket)
1. ผู้อื่นที่เรากด Follow อยู่สร้างห้องใหม่ ➡️ **Django**
2. **Django** สร้าง Notification บันทึกลง DB
3. **Django** ส่งข้อความ Payload ไปใส่ใน **Redis (Port 6379)** ภายใต้กลุ่มของ User ID นั้น
4. **Daphne (Port 8000)** ที่รันเป็น ASGI ฟังอยู่ พบข้อความใน Redis ➡️ ดูดออกมายิง Push ลงท่อ WebSocket (`/ws/notifications/`) 
5. แอป **Flutter** ขึ้นแจ้งเตือน In-App Snack / Badge โดยไม่ต้อง Refresh หน้า

---

## 🛡 สรุปเทคโนโลยีและขอบเขต

| Service | Technology | Internal Port | External Proxy Rule | วัตถุประสงค์หลัก |
|---|---|---|---|---|
| **API & Логика** | Django + Daphne | 8000 | `/api/*`, `/ws/*` | ประมวลผลหลัก, เชื่อมโยงทุกอย่างเข้าด้วยกัน |
| **Media Server** | LiveKit | 7880, 7882 | `livekit.vivaclubs.site` | สตรีมมิ่งเสียง, สร้างห้อง, Sync สถานะระหว่างคนในห้อง |
| **Database** | PostgreSQL | 5432 | *ไม่เปิดออกนอก* | เก็บข้อมูลผู้ใช้งาน โพสต์ ประวัติ และสถานะถาวร |
| **Message Queue** | Redis | 6379 | *ไม่เปิดออกนอก* | เป็นท่อพักข้อมูล WebSocket (Channel Layer) |
| **Admin Panel** | Next.js | 3000 | `admin.vivaclubs.site` | ให้แอดมินดูแดชบอร์ด จัดการยูสเซอร์ |
| **Proxy Gateway** | Caddy | 80, 443 | `*` ทั่วโลก | ทำ SSL และกำหนดทางแยกของทราฟฟิกขาเข้า |

สถาปัตยกรรมนี้ทำให้ **สามารถ Scale ฝั่ง LiveKit แยกกับ Backend ได้** หากวันข้างหน้ามีคนคุยพร้อมกันเป็นระดับหมื่นคน ก็เพิ่มเครื่อง LiveKit (เป็นแบบ Cluster) ส่วนฐานข้อมูลและ API ยังทำงานรวดเร็วแยกส่วนของใครของมัน.
