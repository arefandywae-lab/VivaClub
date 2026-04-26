# บทที่ 4: สถาปัตยกรรมแอปพลิเคชันโมบายล์ (Flutter Mobile Application)
# Chapter 4: Flutter Mobile Application Architecture

---

## 4.1 ภาพรวมสถาปัตยกรรม (Architecture Overview)

แอปพลิเคชัน VivaClub พัฒนาขึ้นด้วยเฟรมเวิร์ก Flutter โดยใช้สถาปัตยกรรมแบบ **Clean Architecture** ร่วมกับรูปแบบการจัดการสถานะ (State Management) แบบ **BLoC (Business Logic Component)** เพื่อแยกส่วนการแสดงผล (UI) ออกจากตรรกะทางธุรกิจอย่างเด็ดขาด

### เทคโนโลยีที่เลือกใช้ (Technology Stack)
- **Framework:** Flutter 3.x (รองรับทั้ง iOS และ Android)
- **State Management:** `flutter_bloc` เพื่อจัดการสถานะที่ซับซ้อนแบบ Reactive
- **Navigation:** `go_router` สำหรับการจัดการเส้นทางแบบ Declarative
- **Networking:** `dio` พร้อมระบบ Interceptor สำหรับการสื่อสารกับ Backend
- **Media:** `livekit_client` สำหรับระบบห้องสนทนาเสียงและวิดีโอคอล

---

## 4.2 การจัดการสถานะด้วย BLoC Pattern

หัวใจของแอปพลิเคชันคือการใช้ BLoC ในการจัดการเหตุการณ์ (Events) และสถานะ (States) โดยแบ่งออกเป็น 3 ชั้นหลัก:
1. **Presentation Layer:** รับ Input จากผู้ใช้และส่งเป็น Event ไปยัง BLoC
2. **Business Logic Layer (BLoC):** ประมวลผล Event และเปลี่ยนสถานะ (Emit State) กลับไปยัง UI
3. **Data Layer (Repository):** ทำหน้าที่ดึงข้อมูลจาก API หรือฐานข้อมูลท้องถิ่น

ตัวอย่างที่สำคัญคือ **AuthBloc** ซึ่งจัดการสถานะการเข้าสู่ระบบทั้งหมด ตั้งแต่การตรวจสอบ Token เมื่อเปิดแอป จนถึงการนำทางผู้ใช้ไปยังหน้าจอที่ถูกต้องตามบทบาท (Role)

---

## 4.3 ระบบนำทางและการรักษาความปลอดภัย (Navigation & Auth Guard)

ระบบใช้ `go_router` ในการจัดการเส้นทาง โดยมีการฝัง Logic **Auth Guard** ไว้ในระบบนำทาง:
- หากผู้ใช้ยังไม่ได้ล็อกอิน ระบบจะบังคับให้นำทางไปยังหน้า Welcome/Login โดยอัตโนมัติ
- มีการแยกเส้นทาง (Routes) อย่างชัดเจนระหว่าง Patient Portal และ Doctor Portal เพื่อป้องกันการเข้าถึงฟังก์ชันข้ามบทบาท

---

## 4.4 ชั้นการสื่อสารข้อมูล (Network Layer & Interceptors)

ในการสื่อสารกับ REST API ระบบใช้แพ็กเกจ `dio` ซึ่งมีการปรับแต่ง **Interceptors** เพื่อเพิ่มความปลอดภัยและประสิทธิภาพ:
- **Request Interceptor:** ใส่ JWT Token ใน Header ของทุกรีเควสต์โดยอัตโนมัติ
- **Response Interceptor:** ตรวจสอบข้อผิดพลาด 401 (Unauthorized) เพื่อพยายามรีเฟรช Token ใหม่เบื้องหลัง ทำให้ผู้ใช้ไม่ต้องล็อกอินซ้ำบ่อยๆ

---

## 4.5 การรวมระบบสื่อสารเรียลไทม์ (LiveKit Integration)

ระบบวิดีโอคอลและห้องเสียงใช้การทำงานร่วมกับ LiveKit ผ่าน `LiveKitRoomService` ซึ่งถูกออกแบบเป็น Singleton ที่ระดับ Root ของแอปพลิเคชัน เพื่อให้เสียงหรือวิดีโอสามารถทำงานต่อเนื่องได้แม้ผู้ใช้จะเปลี่ยนหน้าจอไปมาภายในแอป (Seamless Audio Experience)

---

## 4.6 การจัดเก็บข้อมูลที่ปลอดภัย (Secure Storage)

เนื่องจากความอ่อนไหวของข้อมูลสุขภาพจิต ระบบจึงเลือกใช้ `flutter_secure_storage` ในการเก็บรหัสประจำตัว (JWT Tokens) บนดิสก์ด้วยการเข้ารหัสระดับฮาร์ดแวร์ (Keychain บน iOS และ KeyStore บน Android) แทนการใช้ SharedPreferences แบบปกติที่เก็บข้อมูลเป็นข้อความธรรมดา

---

## 4.7 การออกแบบส่วนต่อประสานผู้ใช้ (UI/UX Design System)

ระบบออกแบบมาภายใต้แนวคิด **"Compassionate Design"** ที่เน้นความสบายใจของผู้ใช้:
- **Color Palette:** ใช้โทนสีอ่อนและไล่เฉดสี (Gradients) เพื่อลดความตึงเครียด
- **Dark Mode:** รองรับ OLED Black เพื่อความสบายตาในเวลากลางคืนและประหยัดพลังงาน
- **Responsive Layout:** ใช้ `flutter_screenutil` เพื่อปรับขนาด UI ให้เหมาะสมกับหน้าจอสมาร์ทโฟนทุกขนาด

### ระบบตัวตนเสมือน (Ghost Avatar System)
แอปพลิเคชันใช้ระบบ Emoji Render สำหรับ Ghost Profile เพื่อความรวดเร็วในการแสดงผลและลดการใช้ข้อมูลอินเทอร์เน็ตในการโหลดรูปภาพ ช่วยให้ผู้ใช้รู้สึกเป็นอิสระและกล้าที่จะแสดงออกในชุมชนมากขึ้น
