# Daily Problem & Progress Report
**Date:** 2026-02-28 to 2026-03-01

## 📌 สรุปสิ่งที่ทำไป (What We Accomplished)

ช่วงที่ผ่านมาเราได้โฟกัสเรื่องการแก้บั๊กสำคัญที่ Block การใช้งานฝั่ง Production (VPS) และการปรับปรุง UX/UI ในห้อง Live Room บนแอป Flutter รวมถึงปัญหาเสียงกระตุกของ Bot Service 

### 1. 🐛 การแก้บั๊กบน Production (VPS & Backend)
- **Redis WebSocket Error (`'tuple' object has no attribute 'decode'`):**
  - **ปัญหา:** Django Channels ไม่สามารถเชื่อมต่อ Redis ได้เพราะใน `settings.py` ใช้ config แบบ Tuple `('host', port)` ซึ่ง `channels_redis` เวอร์ชั่นใหม่ไม่รองรับ
  - **วิธีแก้:** เปลี่ยนการเขียน `CHANNEL_LAYERS` เป็นรูปแบบ URL String `redis://:password@host:port/1` ทำให้ WebSocket เชื่อมต่อได้สำเร็จและเรียลไทม์ทำงานได้
- **Next.js Admin Dashboard (401 Unauthorized & Logout):**
  - **ปัญหา:** Token หมดอายุแล้วตี 401 แต่ระบบไม่เตะออกหน้า Login และปุ่ม Logout ล้าง Token ไม่หมด
  - **วิธีแก้:** แก้ไข Next.js middleware และใช้ `js-cookie` เข้ามาช่วยล้างคุกกี้ที่เก็บ Token ออกหมดจดเมื่อกด Logout
- **API `AllowAny` บน Registration/Login:**
  - **ปัญหา:** ตั้ง `DEFAULT_PERMISSION_CLASSES` เป็น `IsAuthenticated` ทั้งโปรเจกต์ ทำให้ยิง API Login ไม่ผ่าน
  - **วิธีแก้:** สร้าง View ครอบ SimpleJWT (`PublicTokenObtainPairView`) และกำหนด `permission_classes = [AllowAny]` เฉพาะเส้นนี้
- **Invite Speaker 500 Error (`name 'json' is not defined`):**
  - **ปัญหา:** ยิง API ดึงคนขึ้นมาพูดแล้วพัง 500
  - **วิธีแก้:** ย้าย `import json` ไปไว้ระดับบนสุดของไฟล์ `views.py` ให้ทุกฟังก์ชันเรียกใช้ได้

### 2. 📱 การปรับปรุง Flutter App (Live Room)
- **ระบบ Drag-to-Invite (ลากเพื่อดึงคนขึ้นมาพูด):**
  - **สิ่งที่ทำ:** รื้อโครงสร้าง `live_room_screen.dart` ใหม่ทั้งหมด เพิ่มกรอบโซน Speaker (ล่องหน) เมื่อ Host กดค้างที่ Listener จะสามารถลากมาปล่อยที่กรอบเพื่อเชิญขึ้นมาเป็น Speaker ได้ทันที 
- **ระบบ Listener Count เพี้ยน (นับเบิ้ล):**
  - **ปัญหา:** จอยห้องคนเดียวแต่เลขนับ 2
  - **วิธีแก้:** ลบการ +1 / -1 ออกจาก API Join/Leave แล้วให้ LiveKit Webhooks (`participant_joined`, `participant_left`) เป็น Single Source of Truth ในการนับจำนวนคน
- **เชื่อมระบบ Follow ในห้อง Live Room หน้า Profile Card:**
  - **ปัญหา:** ปุ่ม Follow เดิมขึ้นแค่ SnackBar หลอกๆ ไม่ได้เชื่อม Backend สังเกตว่าหน้าต่างใน Live Room ใช้ User ID แต่ API ใช้ Ghost ID
  - **วิธีแก้:** ฝั่ง Backend แนบ `ghost_id` ใส่ไปใน LiveKit Metadata ตอน Join ห้อง และฝั่ง Flutter ถอดค่านี้ออกมาโยนเข้า `FollowingBloc` ทำให้กดติดตามจากในห้องได้จริง
- **การจัดการตอนถูก Kick เตะออกจากห้อง:**
  - **ปัญหา:** Host เตะคนออก แต่เครื่องปลายทางยังค้างอยู่หน้าห้อง พยายาม Publish ไมค์จนเกิด Exception รัวๆ
  - **วิธีแก้:** ใน Flutter ดักฟัง `RoomDisconnectedEvent` ภายใน LiveKit Service หากดักได้ว่าค้าง ให้เช็คสถานะและแสดง SnackBar "You were removed" พร้อมเด้งกลับหน้า Dashboard อัตโนมัติ
- **อัปเดตโลโก้แอป:**
  - ใช้โฟลเดอร์ `Assets/images` เปลื่ยนโลโก้นกเหยี่ยวเป็นโลโก้หลักของ VivaClub (`flutter_launcher_icons`)

### 3. 🤖 ปัญหา AI Bot Service
- **เสียง Bot กระตุก / ขาดๆ หายๆ:**
  - **ปัญหา:** ใช้ `asyncio.sleep(FRAME_DURATION)` แล้วเกิดเวลาสะสม (Drift) ทำให้ส่งเฟรมเสียงไม่ตรงกับจังหวะเวลาจริงของ LiveKit
  - **วิธีแก้:** เปลี่ยนไปอิงตามนาฬิการะบบ `time.monotonic()` เพื่อคำนวณเวลาพักของแต่ละลูป (Pacing) และปรับเฟรมเสียงเป็น 10ms (480 samples ต่อเฟรม) เสียงจึงลื่นไหลขึ้น

## 📋 ข้อสังเกตและงานถัดไป (Next Steps)
- การใช้ LiveKit Metadata ช่วยให้ Backend ส่งข้อมูลถึง Client ได้ง่ายขึ้นโดยไม่ต้องยิง API เพิ่ม (เช่น เก็บ `role`, `host`, `speaker`, `handRaised`, `ghost_id`)
- ทุกครั้งที่ทำ Action ผ่าน Backend (เช่น invite, kick) จะต้องระวังไม่ไปเขียนทับ Metadata เดิมของ LiveKit (ต้องดึงของเก่ามาผสานข้อมูลใหม่เสมอ)
- งานถัดไป: ทดสอบความเสถียรของ Push Notification ตอนแจ้งเตือน Follower ว่าเริ่มเปิดห้อง
