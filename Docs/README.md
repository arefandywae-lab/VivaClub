# VivaClub Documentation Directory

ยินดีต้อนรับสู่ศูนย์กลางเอกสาร (Documentation) ของโปรเจกต์ **VivaClub** 
โครงสร้างโฟลเดอร์นี้ถูก Clean & Merge เอกสารทั้งหมดให้อัปเดตและตรงกับโค้ดปัจจุบัน (ณ เดือนกุมภาพันธ์ 2026) เพื่อให้ง่ายต่อการค้นหาและนำไปใช้งานต่อ

## 🗂 โครงสร้างเอกสารปัจจุบัน (Current Documentation)

เอกสารหลักถูกแบ่งออกเป็น 5 หมวดหมู่ ตามหมายเลขเพื่อให้ลำดับการอ่านง่ายขึ้น:

1. **[1_System_Architecture.md](./1_System_Architecture.md)**
   > ภาพรวมของระบบ (System Design) การแยกส่วน Frontend/Backend และกลไกของ LiveKit WebRTC
2. **[2_API_Reference.md](./2_API_Reference.md)**
   > รายชื่อ API ทั้งหมดที่ใช้งานปัจจุบัน (Authentication, ห้องสนทนา, ระบบ Mute/Kick) พร้อม Payload
3. **[3_Database_Schema.md](./3_Database_Schema.md)**
   > โครงสร้างตารางฐานข้อมูล PostgreSQL (User, GhostProfile, Room) และระบบ Security (PBKDF2/JWT)
4. **[4_QA_And_Testing.md](./4_QA_And_Testing.md)**
   > คู่มือการรันสคริปต์ทดสอบ (Automated Tests) จากโฟลเดอร์ `scripts/testing/` และผลลัพธ์ครอบคลุม (Test Coverage)
5. **[5_iOS_Deployment.md](./5_iOS_Deployment.md)**
   > คู่มือการรันแอปพลิเคชัน Flutter บนอุปกรณ์เครื่องจริง (iPhone) ทั้งรูปแบบเสียบสาย (Debug) และถอดสาย (Standalone/Release)

## 🗃 Archive (เอกสารเก่า)
เอกสารเก่า บันทึกปัญหา (Bug logs) และผลทดสอบสคริปต์ในช่วงแรกๆ ของการพัฒนา เช่น `discovery_api.md`, `solution.md` ได้ถูกย้ายไปเก็บรักษาไว้ที่โฟลเดอร์ **`/Archive/`** เพื่อไม่ให้เกะกะการทำงานในปัจจุบันครับ
