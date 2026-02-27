# 2. API Reference (คู่มือเส้นทาง API หลัก)

เส้นทาง API ทั้งหมดปัจจุบัน ถูกโฮสต์บนเซิร์ฟเวอร์ (Railway) ทำงานภายใต้โปรโตคอล `HTTPS` และรับข้อมูลแบบ `application/json`

*(หมายเหตุ: เกือบทุก API ต้องแนบ Header `Authorization: Bearer <ACCESS_TOKEN>` เสมอ ยกเว้นกลุ่มล็อกอินลงทะเบียน)*

## 2.1 Authentication & User Profiles
---
### POST `/api/auth/register/`
- **หน้าที่:** สร้างบัญชีใหม่ 
- **Payload:** `{"email": "abc@mail.com", "username": "user", "password": "123"}`

### POST `/api/auth/login/`
- **หน้าที่:** รับ `access_token` และ `refresh_token`
- **Payload:** `{"email": "abc@mail.com", "password": "123"}`

### GET `/api/auth/profile/`
- **หน้าที่:** ดึงโปรไฟล์ คลาส Role หมอ/คนไข้ และ Display Name

## 2.2 Community Rooms (ห้องเสียงสาธารณะ)
---
### GET `/api/community/rooms/`
- **หน้าที่:** ดึงรายการห้องเสียง (List) ที่มีอยู่บนแพลตฟอร์มทั้งหมด

### POST `/api/community/rooms/`
- **หน้าที่:** สร้างห้องสนทนาใหม่
- **Payload:** `{"title": "ห้องคุยเรื่องสุขภาพ", "description": "มาคุยกันครับ"}`

### POST `/api/community/rooms/<room_id>/join/`
- **หน้าที่:** ขอ `LiveKit Access Token` เพื่อผูกติด Connection เข้าเป็นผู้พูดโต้ตอบสด

### POST `/api/community/rooms/<room_id>/leave/`
- **หน้าที่:** ออกจากห้องสนทนา และคืนทรัพยากรแบนด์วิธ

## 2.3 Room Moderation (การจัดการสมาชิกโดย Host)
---
*(API หมวดหมู่นี้ ใช้งานได้เฉพาะบุคคลที่เป็น "Host" ควบคุมห้องเท่านั้น โดย Backend จะเชื่อมกับ Twirp SDK สั่งตัดสัญญาณสตรีมเมอร์)*

### POST `/api/community/rooms/<room_id>/invite/`
- **หน้าที่:** เชิญคนฟังขึ้นมาเป็นคนพูด
- **Payload:** `{"identity": "<LiveKit_User_Identifier>"}`

### POST `/api/community/rooms/<room_id>/mute-participant/`
- **หน้าที่:** สั่งปิดไมโครโฟนของผู้ใช้คนอื่นทันที (Force Mute) โดยคำสั่งจากระยะไกล
- **Payload:** `{"identity": "<User_ID>", "track_sid": "<Microphone_Track_ID>"}`

### POST `/api/community/rooms/<room_id>/kick-participant/`
- **หน้าที่:** ตัดการเชื่อมต่อ บังคับยุติ WebRTC ทันที เตะคนป่วนออก
- **Payload:** `{"identity": "<User_ID>"}`
