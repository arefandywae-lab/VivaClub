# 3. Database Schema & Security (ฐานข้อมูลและความปลอดภัย)

โปรเจกต์ VivaClub ใช้ฐานข้อมูลเชิงสัมพันธ์ **PostgreSQL** เป็นตัวเก็บ State ถาวรทั้งหมด โดยควบคุมการสร้างตารางและแก้ไขผ่านเทคโนโลยี `Django ORM` (Object-Relational Mapping)

## 3.1 ตารางฐานข้อมูลหลัก (Core Tables)

### ตาราง `User` (Custom User Model)
เป็นโมเดลหลักสำหรับจัดการ Authentication ควบคุมโดยไลบรารีเบื้องหลัง (Djoser)
- `id`: UUID (Primary Key ป้องกันการเดาไอดี)
- `email`: อีเมลหลักใช้ล็อกอิน (Unique)
- `username`: ชื่ออ้างอิงของแต่ละระบบ
- `password`: รหัสผ่าน **(ไม่แสดงผล เก็บในรูปแบบ Hashing)**

### ตาราง `GhostProfile`
ตารางนี้เชื่อมกับ `User` แบบ 1-to-1 (One-to-One Field) หน้าที่คือเป็น "Profile" โชว์หน้าบ้าน:
- `user`: Foreign Key ไปยังตาราง User
- `display_name`: ชื่อโปรไฟล์ที่จะโชว์ให้คนอื่นเห็น
- `avatar_path`: เส้นทางการเก็บรูปโปรไฟล์ (URL/Path)
- `role`: เก็บประเภทบัญชี เช่น `patient` (คนไข้ทั่วไป/ผู้ฟัง), `doctor` (หมอ/ผู้เชี่ยวชาญ)
- `bio`: ข้อความแนะนำตัวย่อๆ ของหมอ

### ตาราง `Room` (ห้องข้อความเสียง)
ตารางนี้เก็บประวัติและสถานะการมีอยู่ของห้อง Clubhouse
- `id`: Primary Key (UUID)
- `title`: หัวข้อ/ชื่อห้องสนทนา
- `description`: คำอธิบายห้อง
- `host`: Foreign Key กลับไปหา `GhostProfile` ของคนที่เป็นผู้สร้าง
- `status`: สถานะของห้อง (`active` หรือ `ended`)
- `created_at` / `ended_at`: Timestamp วัน-เวลา 

---

## 3.2 ความปลอดภัยและการเข้ารหัสลับ (Encryption & Security Methods)

1. **Password Encryption (At Rest):** 
   - รหัสผ่านจะถูก Hash ก่อนบันทึกลงฐานข้อมูลเสมอด้วยกลไก **PBKDF2 (Password-Based Key Derivation Function 2)** พร้อมกลไกผสมเกลือ (HMAC-SHA256) ป้องกันการถูกถอดรหัส (Crack) แม้ฐานข้อมูลจะรั่วไหล
2. **Access Token (In Memory):** 
   - ระบบ Login แจกจ่ายกุญแจแบบ **JSON Web Token (JWT)**
   - Token จะมีอายุจำกัด เพื่อลดความเสี่ยงจากการขโมยอุปกรณ์
3. **Data Transport Encryption (In Transit):** 
   - ทุกๆ Request สู่ API จะวิ่งผ่านโปรโตคอล **HTTPS (TLS 1.2/1.3)** เพื่อซ่อนข้อมูล
   - ข้อมูลเสียง (Voice audio packets) มีการเข้ารหัสตั้งแต่ต้นทางยันปลายทาง (End-to-End) ด้วยโปรโตคอล **SRTP (Secure Real-time Transport Protocol)** ดูแลโดย LiveKit
4. **Client Secret Storage (Mobile):** 
   - รหัสผ่าน Token ของผู้ใช้ จะถูกฝังลึกใน OS โดยการใช้ไลบรารี `flutter_secure_storage` 
   - **iOS:** บันทึกเข้าฐาน **Apple Keychain**
   - **Android:** บันทึกเข้า **Android Keystore**
