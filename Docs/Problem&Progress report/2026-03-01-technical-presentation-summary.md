# 🎯 Technical Solution & Architecture Justification (VivaClub)

เอกสารสรุปประกอบการนำเสนอ (Presentation) เพื่อใช้อธิบายแนวคิดเชิงวิศวกรรม (Engineering Decisions) โครงสร้างสถาปัตยกรรม ข้อจำกัด และเหตุผลในการเลือกใช้เทคโนโลยีต่างๆ ในโปรเจกต์ VivaClub

---

## 1. ทำไมถึงเลือกใช้ Tools เหล่านี้? (Technology Stack Justification)

การเลือกเทคโนโลยีในโปรเจกต์นี้ มุ่งเน้นไปที่ **"ความสามารถในการขยายตัว (Scalability)"** และ **"การรองรับการทำงานแบบ Real-time"**

*   **📱 Frontend (Flutter):** 
    *   **เหตุผล:** เป็น Cross-platform ที่รองรับการทำแอปมือถือทั้ง iOS และ Android จาก Codebase เดียว และมี Library ที่รองรับ WebRTC (LiveKit) ได้อย่างมีประสิทธิภาพระดับ Native ทำให้การจัดการเสียง (Audio Stream) ทำได้เสถียร
*   **⚙️ Backend (Django + Django Channels / Daphne):**
    *   **เหตุผล:** Django มีระบบ ORM และ Admin ที่แข็งแกร่งช่วยให้สร้าง API พื้นฐานได้เร็ว ส่วน **Django Channels** เข้ามาช่วยรับมือกับ WebSockets (Async) เพื่อทำ Real-time Notification ส่งแจ้งเตือนเวลามีคนกดติดตาม หรือเข้าห้อง
    *   นอกจากนี้ Python ยังมีไลบรารีจัดการ Audio/Media สตรีมมิ่งที่แข็งแกร่ง ทำให้ง่ายต่อการเขียน **Music Bot / Testing Bot** เพื่อสตรีมเพลงเข้าห้อง
*   **📡 Message Broker & Queue (Redis):**
    *   **เหตุผล:** ใช้ทำ Pub/Sub เพื่อเป็นคนกลางกระจายข้อความ (Broadcast) ระหว่าง WebSockets หลายๆ Connection และใช้เป็นคิว (Task Queue) สำหรับสั่งงาน Background Worker (เช่น โยนงานไปให้ Music Bot เข้าห้องเป้าหมาย)
*   **🗄️ Database (PostgreSQL):**
    *   **เหตุผล:** เป็น Relational Database ที่มีความเสถียร (ACID Compliance) เหมาะสำหรับการเก็บข้อมูลที่มีความสัมพันธ์กันซับซ้อน เช่น User, Room, Session และ Metadata ต่างๆ
*   **💻 Admin Dashboard (Next.js):**
    *   **เหตุผล:** ใช้สร้าง UI สำหรับผู้ดูแลระบบได้รวดเร็ว (React/Tailwind) รองรับ SSR/CSR และไม่ต้องเอาไปรวมกับ Django Backend ทำให้แยกโหลดการทำงาน (Decoupling) หน้าบ้านและหลังบ้านได้ชัดเจน

---

## 2. ทำไมถึงใช้ LiveKit? (Audio/Video Infrastructure)

ระบบของเราคือ Audio Drop-in Application ถ้าเราเขียน WebRTC ขึ้นมาเองแบบ Peer-to-Peer (Mesh) โทรศัพท์มือถือ 1 เครื่องจะต้องส่งเสียงหาคน 10 คนพร้อมกัน (Bandwidth มือถือจะรับไม่ไหว และแบตเตอรี่จะหมดไวมาก)

*   **LiveKit คืออะไร?:** เป็น Open-source WebRTC Infrastructure ระดับโลก ที่ทำงานแบบ **SFU (Selective Forwarding Unit)**
*   **หลักการทำงาน:** มือถือของผู้พูด (Speaker) จะส่งแพ็กเก็ตเสียง (UDP) ขึ้นไปที่ Server ของ LiveKit เพียงแค่ **1 เส้น** เท่านั้น จากนั้น Server จะทำหน้าที่ "กระจาย (Forward)" เสียงนั้นไปให้คนฟัง (Listeners) อีกร้อยคนพันคนเอง ช่วยลดโหลดของแอปมือถือได้อย่างมหาศาล
*   **มีใครใช้ LiveKit บ้าง (Industry Examples):**
    *   **OpenAI:** ใช้ LiveKit เป็น Infrastructure เบื้องหลังสำหรับ **Realtime API** (ChatGPT Advanced Voice Mode ในบางโซลูชัน)
    *   **Character.AI:** ใช้สำหรับระบบคุยสายสนทนากับ AI
    *   **Meet, Inworld AI, และแอป Social คุยเสียงชั้นนำ:** นิยมนำไปปรับแต่งใช้เพื่อรองรับคนคุยพร้อมกันจำนวนมากแบบ Low Latency

---

## 3. ทำไมต้องเช่า VPS (Virtual Private Server) แทนที่จะใช้ Cloud PaaS ทั่วไป?

ในตอนเริ่มทำโปรเจกต์ ผู้พัฒนาส่วนใหญ่มักจะใช้ PaaS ฟรี หรือสำเร็จรูป (เช่น Vercel, Heroku, Render) แต่โครงสร้างระดับนี้ **"ทำไม่ได้"** เนื่องจากข้อจำกัดต่อไปนี้:

1.  **ข้อจำกัดเรื่อง Port และ Protocol (หัวใจสำคัญ):** 
    *   บริการ Cloud PaaS ส่วนใหญ่จะเปิดให้ใช้แค่ Port `80` (HTTP) และ `443` (HTTPS) 
    *   แต่ **LiveKit ต้องการคุยผ่านโปรโตคอล UDP (Port 7882)** เพื่อให้เสียงมีความหน่วงต่ำที่สุด (Ultra-low Latency) การคุยผ่าน TCP/HTTP จะทำให้เสียงดีเลย์ หากใช้ PaaS เราจะไม่สามารถเจาะพอร์ต UDP หรือ Custom Ports แบบนี้ได้เลย
2.  **สถาปัตยกรรมแบบ Multi-Container (Microservices):**
    *   โปรเจกต์ประกอบด้วยคอนเทนเนอร์หลายตัวที่ต้องทำงานคุยกันในวง Network ภายใน (Backend, Frontend, Redis, Postgres, LiveKit, Bot Worker) การเช่า VPS (เช่น DigitalOcean, AWS EC2, หรือ Cloud ทั่วไปที่เป็นแบบ VM) ทำให้เราสร้างโครงสร้าง Docker Compose ภายใน Server เดียวกันได้อย่างอิสระ
3.  **การรันงานแบบ Background Process:**
    *   PaaS บางที่มี Time-out (ตัวอย่างเช่น ตัดจบ Request ภายใน 30 วินาที) แต่ **Music Bot / โฮสต์ทดสอบ** ของเราต้องเปิด Connection WebRTC ค้างไว้เพื่อสตรีมเพลงต่อเนื่องหลายชั่วโมง (Long-lived connections + WebSockets) VPS จึงตอบโจทย์กว่า
4.  **ความคุ้มค่า (Predictable Cost):** 
    *   การประมวลผล WebRTC และการทำ Audio Streaming ใช้ Bandwidth ค่อนข้างเยอะ การใช้ VPS แบบเหมาจ่ายต่อเดือนจึงประหยัดและคุมงบประมาณได้ชัวร์กว่าแบบ Pay-per-use

---

## 4. อธิบาย Port Mapping เบื้องต้น (ประตูต้อนรับของระบบ)

เพื่อให้ Traffic เข้าสู่ Service ที่ถูกต้องตามหน้าที่ใน VPS เราใช้ **Caddy Proxy** เป็นยามเฝ้าประตูด้านหน้า และจัดการ Map Ports ดังนี้:

*   **🌐 [Port 80 / 443] Gateway (Caddy):**
    *   เปิดรับ Request จริงจากคนข้างนอก และทำ Auto-SSL (HTTPS) จากนั้นจะส่ง Traffic วิ่งไปหา Service ข้างในตาม Path ที่กำหนด (Reverse Lookup)
*   **🛠️ [Port 8000] Django API & Daphne:** 
    *   ซ่อนอยู่หลัง Caddy รับข้อมูลที่เป็น HTTP API ปกติ (`/api/*`) และ WebSockets Connection (`/ws/*`)
*   **📊 [Port 3000] Next.js Dashboard:** 
    *   หน้าจอผู้ดูแลระบบ ทำงานเป็น Internal UI
*   **📡 [Port 7880] LiveKit Signaling (TCP/WS):** 
    *   เอาไว้จัดการจองห้อง (Room Handshake), เช็คสิทธิ์ (Token Auth) และควบคุมห้องด้วย WebSockets
*   **🎧 [Port 7882] LiveKit Media (UDP/TCP):** 
    *   **พอร์ตพิเศษสำหรับ WebRTC Audio Stream** มือถือของผู้ใช้จะส่งคลื่นเสียงอัดผ่านโปรโตคอล UDP วิ่งเข้าพอร์ตนี้โดยตรง เพื่อหลีกเลี่ยง Overhead ของ HTTP ทำให้ส่งเสียงได้ Real-time ระดับหลักมิลลิวินาที 
*   **🔒 [Port 5432 & 6379] Postgres & Redis (Internal Only):** 
    *   **ไม่เปิดสู่โลกภายนอก (No Port Forwarding)** เพราะเป็นความลับระดับฐานข้อมูล ให้เฉพาะคอนเทนเนอร์ด้วยกันเองเท่านั้นที่เชื่อมต่อได้
