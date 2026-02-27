# 1. System Architecture (สถาปัตยกรรมระบบ)

**VivaClub** เป็นแอปพลิเคชันโซเชียลเน็ตเวิร์คทางเสียงแบบเรียลไทม์ (Audio-first community) ที่โครงสร้างระบบถูกออกแบบในลักษณะ **Decoupled Architecture** แยกส่วนกันอย่างชัดเจนตามหน้าที่ (Separation of Concerns)

## 1.1 Tech Stack ภาพรวม
- **Mobile Client (Frontend):** พัฒนาด้วย **Flutter (Dart)** รองรับ Cross-platform (iOS/Android) 
- **Backend API:** พัฒนาด้วย **Django & Django REST Framework (Python)** จัดการ Business Logic และ Database
- **Database:** **PostgreSQL** บน Railway
- **Audio Signaling Server (WebRTC):** **LiveKit Cloud** ทำหน้าที่เป็น SFU (Selective Forwarding Unit) กระจายเสียงสดความหน่วงต่ำ
- **Deployment & Cloud:** รันคอนเทนเนอร์ (Docker) บน **Railway.app (PaaS)**

## 1.2 โฟลว์การทำงานหลัก (Core Communication Flow)
เมื่อผู้ใช้งาน (Mobile App) ต้องการสร้างห้อง หรือเข้าห้องสนทนาเสียง:
1. **Request:** แอปพลิเคชัน Flutter จะแนบ `JWT Access Token` แล้วยิง API (HTTPS) ไปหา Django Backend เพื่อขอเข้าร่วมห้อง (Join Room)
2. **Database Verification:** Backend ตรวจสอบสิทธิ์ว่ายูเซอร์มีสิทธิ์เข้าห้องหรือไม่ บันทึกข้อมูลประวัติลง PostgreSQL
3. **LiveKit Integration:** หากผ่านสิทธิ์ Backend จะทำการเรียกฟังก์ชันสร้าง **WebRTC Access Token** โดยใช้ `LIVEKIT_API_KEY` และ `LIVEKIT_API_SECRET`
4. **Token Delivery:** Backend โยน Token กลับไปให้มือถือผ่าน JSON Response
5. **WebRTC Connection:** ฝั่งมือถือ (Flutter) นำ Token นั้น ไปต่อท่อตรง (WebSocket - WSS) เข้าสู่ก้อนเซิร์ฟเวอร์ **LiveKit** โดยตรง
6. **Streaming:** อุปกรณ์มือถือหลายสิบเครื่องจะสตรีมเสียงหากันได้แบบ Low Latency ผ่าน LiveKit โดยที่ไม่ต้องรบกวนแบนด์วิธของเซิร์ฟเวอร์ Django อีกเลย

## 1.3 สถาปัตยกรรมการจัดการ State บน Frontend
ใช้รูปแบบ **BLoC (Business Logic Component)** ในการแยก UI ออกจากข้อมูล
- `AuthBloc`: จัดการการล็อกอิน สมัครสมาชิก และเก็บ Token ลงใน Secure Storage (`flutter_secure_storage`)
- `RoomBloc`: จัดการรายชื่อห้อง ลิสต์ห้องที่มีอยู่
- `LiveKitRoomService`: บริการพิเศษ (Singleton) สำหรับยึดจับ Connection ของ LiveKit (ครอบคลุมฟีเจอร์ ไมค์, เสียง, ยกมือข้ามเครื่องแบบไร้เซิร์ฟเวอร์ผ่าน Metadata)
