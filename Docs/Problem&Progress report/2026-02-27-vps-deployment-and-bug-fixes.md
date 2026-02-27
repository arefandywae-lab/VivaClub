# 🚀 รายงานสรุปความคืบหน้าและการแก้ปัญหา: การนำ VivaClub ขึ้น Contabo VPS

เอกสารฉบับนี้สรุปการเดินทางทั้งหมดตั้งแต่เริ่มต้นย้ายระบบออกจาก Railway/LiveKit Cloud มาตั้งถิ่นฐานใหม่บน **Contabo VPS (Self-Hosted)** แบบเต็มตัว เพื่อเตรียมพร้อมสำหรับการรับโหลดผู้ใช้งานจริง

---

## 📈 1. ภาพรวมความสำเร็จ (Progress Overview)

ปัจจุบันระบบ Backend ของ VivaClub ทำงานบนรันบน Contabo VPS ได้อย่างสมบูรณ์แบบ 100% โดยประกอบด้วย:
- **Django Backend:** ทำงานผ่าน Gunicorn + Caddy (HTTPS/Reverse Proxy)
- **PostgreSQL:** ฐานข้อมูลหลักที่รองรับการเชื่อมต่อจำนวนมากได้เต็มประสิทธิภาพโดยไม่โดน Limit แบบ Railway
- **Redis:** ทำหน้าที่เป็น Broker กลางให้ระบบต่างๆ คุยกัน (เช่น Caddy, Django, LiveKit)
- **LiveKit Server (Self-Hosted):** รันเซิรฟ์เวอร์ WebRTC ของตัวเอง ไม่ต้องกังวลเรื่องโควต้านาทีจาก Cloud อีกต่อไป
- **Monitoring Tools:** ติดตั้ง Portainer (จัดการ Docker) และ Dozzle (ดู Log) พร้อมใช้งาน

**ผลการทดสอบระบบ (Stress Test):**
- รองรับการสร้างผู้ใช้พร้อมกัน 20 คนรวด (สำเร็จ 100%)
- รองรับการสร้างห้องพร้อมกัน 15 ห้อง (สำเร็จ 100%)
- รองรับการกด Join ฟังพร้อมกัน 10 คนในพริบตา
- ฟังก์ชัน API ทั้งหมด 30+ endpoints (Login, Refresh Token, Follow, Room, Discovery, Notifications) ทำงานผ่านฉลุย (Pass Rate 100%)

---

## 🛠️ 2. ปัญหาที่พบระหว่างทาง & วิธีการแก้ไข (Challenges & Resolutions)

การย้ายระบบใหญ่ขึ้น VPS รวดเดียวมักเจอบั๊กซ่อนเร้น นี่คือ 5 ปัญหาหลักที่เราฝ่าฟันมาจนระบบนิ่งสนิท:

### 🔴 ปัญหาที่ 1: ตู้ LiveKit หา Redis ไม่เจอ (Connection Refused / WRONGPASS)
* **อาการ:** LiveKit Server พยายามต่อ Redis แต่โดนเตะออก รหัสผ่านผิด หรือหา Port 6379 ไม่เจอ ทำให้เซิร์ฟเวอร์ตีลังการีสตาร์ทตัวเองตลอดเวลา
* **การแก้ไข:** 
  - เข้าไปแก้ไฟล์ `livekit.yaml` เพื่ออัปเดต URL ของ Redis จากแบบเก่ามาเป็น `redis://:viva-redis-pass@redis:6379/0`
  - ตรวจสอบให้มั่นใจว่ารหัสผ่าน (`viva-redis-pass`) ใน LiveKit ตรงกับรหัสผ่านที่ตั้งไว้ในฝั่ง Redis Container

### 🔴 ปัญหาที่ 2: Caddy ชนหน้าต่าง (Address already in use :443)
* **อาการ:** รัน Caddy ไม่ขึ้น เพราะบน VPS ดันมีโปรแกรม Apache2 แอบทำงานซุ่มอยู่และแย่งชิง Port 80 และ 443 ไปใช้
* **การแก้ไข:** 
  - สั่งปิดและถอนรากถอนโคน Apache2 ออกจากเครื่อง (`systemctl disable --now apache2`) 
  - สั่งรีสตาร์ท Caddy เพื่อให้ Caddy ยึดครอง Port 80, 443 กลับมาจัดการเรื่อง HTTPS อัตโนมัติ

### 🔴 ปัญหาที่ 3: Backend ยิงเข้าหา LiveKit Cloud ตัวเก่า (Error 401 Unauthorized / 502 Bad Gateway)
* **อาการ:** ตอนทดสอบสร้างห้อง ผ่านหมด แต่พอกด Invite หรือ Kick ระบบดันฟ้อง 401/502 ตลอด 
* **การแก้ไข:** 
  - **หาสาเหตุ:** สืบ Log เจอว่าตัวแปรฝั่งหน้าบ้านเขียนใน `.env` ว่า `LIVEKIT_URL` กับ `LIVEKIT_URL_API` แต่ฝั่ง Django หวังจะอ่านคำว่า **`LIVEKIT_API_URL`** 
  - **จุดจบ:** พอชื่อตัวแปรไม่ตรง Django เลยไปดึงสคริปต์เก่าที่ชี้ไปหา `vivaclub-c8l1bt1p.livekit.cloud` 
  - **ลงดาบ:** แก้ชื่อตัวแปรใน `docker-compose.yml` บน VPS ให้เป็น `LIVEKIT_API_URL` สั่ง restart ตู้ Backend อาการหายขาดทันที!

### 🔴 ปัญหาที่ 4: สคริปต์สร้างห้อง Fail ในข้อหา "addiction" 
* **อาการ:** ใน 12 ห้องที่ทดสอบ จะมี 3 ห้องพังเสมอ
* **การแก้ไข:** ตรวจสอบโค้ดพบว่าเป็น Error ฝั่ง "ตัวเทสเอง" ไม่ใช่ฝั่ง Server เพราะสคริปต์ดันสั่งสร้างห้องหมวดหมู่นอกบัญชีอย่าง `addiction` ซึ่ง Database ระบบเราไม่รู้จัก (รับแค่ general, anxiety, depression ฯลฯ) จึงแก้ไขไฟล์ Test ให้ใช้หมวดหมู่ที่ถูกต้อง

### 🔴 ปัญหาที่ 5: API Invite/Mute 500 พังเพราะ SDK ไม่อัปเดต
* **อาการ:** ตอนเขียนโค้ดเรียก LiveKit API จาก Django การเรียก `lkapi.room.update_participant()` ส่ง Error กลับมาเป็น 500
* **การแก้ไข:** 
  - ใน Python SDK ของ LiveKit ยุคใหม่ (Twirp) การแก้ไข Participant (เช่น ให้สิทธิ์พูด, Mute, เตะ) จะต้องโยน Object ควบรวมที่เรียกว่า `update_participant_permissions()` หรือส่งเป็น Request Object ไปแทน
  - ปรับปรุงโค้ดฝั่ง `views.py` ของ Django ให้สร้างและใช้ Data Object พ่วงตามเอกสาร API ของ LiveKit ทำให้ Backend สามารถเปิด/ปิดไมค์ รวมถึงเตะคนออกได้อย่างหมดจด

---

## 🔭 3. ก้าวต่อไป (Next Steps)
พื้นฐานระบบตอนนี้ (Foundation) ถือว่าเกรด A+ พร้อมลุยต่อในสเต็ปที่สนุกขึ้น:
1. **พัฒนาฝั่งแอปมือถือ (Flutter):** ตอนนี้ฝั่ง Server ไม่เป็นตัวถ่วงแล้ว สามารถเอา Endpoint ฝั่งหน้าบ้าน (UI) มาเสียบกับ API จริง 
2. **ระบบ Trust Score:** คัดกรองและประเมินพฤติกรรม Ghost เพื่อสังคมที่ดีขึ้น ตาม Phase 3 
3. **ระบบ Push Notification (FCM):** แจ้งเตือนเมื่อเพื่อนที่ Follow เปิดห้องใหม่ (ต่อยอดจากที่เทส API สำเร็จแล้ว)
