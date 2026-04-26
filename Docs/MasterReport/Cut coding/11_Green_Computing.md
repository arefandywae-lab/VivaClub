# บทที่ 11: Green Computing และความยั่งยืน
# Chapter 11: Green Computing and Sustainability

---

## สารบัญบท / Chapter Contents

11.1 หลักการ Green by Design  
11.2 Client-Side Energy Savings  
11.3 Network Efficiency  
11.4 Server-Side Efficiency  
11.5 การเปรียบเทียบกับ Alternatives  
11.6 Carbon Footprint Considerations  
11.7 สรุป Energy Savings Estimates  

---

## 11.1 หลักการ Green by Design

VivaClub ถูกออกแบบโดยคำนึงถึงการใช้พลังงานตั้งแต่ต้น ไม่ใช่เพิ่มทีหลัง สำหรับแอปสุขภาพจิตที่ผู้ใช้อาจ active อยู่ตลอดคืน (ช่วงวิกฤตจิตใจ) การที่แอปกินแบตน้อยลง = ผู้ใช้ไม่ต้องวางโทรศัพท์ = ยังเข้าถึงความช่วยเหลือได้

**3 เป้าหมายหลัก:**
1. **Client Energy** — แบตเตอรี่ของผู้ใช้หมดช้าลง
2. **Network Bytes** — ใช้ bandwidth น้อยลง
3. **Server Resources** — CPU/RAM บน VPS ใช้อย่างมีประสิทธิภาพ

---

## 11.2 Client-Side Energy Savings

### 1. OLED Dark Mode (Design Goal — แผนการพัฒนาใน V2.0)

แม้ใน MVP 1.0 จะยังใช้ Light Mode เป็นหลักเพื่อความง่ายในการทดสอบ UI แต่โครงสร้างระบบถูกออกแบบมาเพื่อรองรับ **True OLED Black** ในอนาคต ซึ่งจะช่วยประหยัดพลังงานได้มหาศาลบนหน้าจอประเภท OLED

**หลักการ OLED:** pixel สีดำ (RGB 0,0,0) ปิดไฟ LED โดยสมบูรณ์ = กินไฟ 0W ต่อ pixel นั้น บน OLED screen ที่มีพื้นหลังดำ 60% ของ pixels ปิดอยู่ → ประหยัดพลังงาน 30–50% เมื่อเทียบกับ white background

**แผนการพัฒนา:** ใน Version 2.0 แอปจะเพิ่มตัวเลือก Dark Mode เป็นค่าเริ่มต้น (System Default) เพื่อลดการใช้แบตเตอรี่ในกลุ่มผู้ใช้งานช่วงกลางคืน ซึ่งเป็นช่วงเวลาวิกฤตที่มีการใช้งานแอปสูงสุด

---

### 2. Emoji-Based Ghost Avatars (Zero Image Bandwidth)

**เปรียบเทียบ:**
| Method | Bandwidth per avatar | Storage |
|--------|---------------------|---------|
| Photo avatar (JPG, 100px) | ~8 KB | CDN storage cost |
| Vector avatar (SVG) | ~2 KB | CDN storage cost |
| **Emoji (VivaClub)** | **0 bytes** | **$0** |

สำหรับ community ที่มี user 10,000 คน emoji approach ประหยัด ~80 MB bandwidth ต่อวัน (เฉลี่ย 1 avatar view ต่อ user ต่อวัน)

---

### 3. Vector Icons — No Bitmap Assets

Vector icons scale ไม่มี quality loss ไม่ต้องเก็บหลาย density → App bundle เล็กลง ~2-5 MB

---

### 4. ScreenUtil Responsive Layout — ป้องกัน Layout Thrashing

Responsive scaling ที่ถูกต้องป้องกัน overflow errors ที่ทำให้ Flutter rebuild ซ้ำๆ Rebuild ที่ไม่จำเป็น = CPU spike = battery drain

---

### 5. BLoC Pattern — Precise Rebuilds

`buildWhen` ป้องกัน unnecessary rebuilds เมื่อ state fields อื่นเปลี่ยน

---

## 11.3 Network Efficiency

### 1. WebSocket vs Polling (ประหยัด ~95% ของ notification bandwidth)

### 2. Lazy Loading ใน Room List และ Profile History

### 3. PHQ-9 24-Hour Cooldown — ป้องกัน Unnecessary API Calls

ป้องกัน user ที่อยากรู้ผล tap assessment button ซ้ำๆ — ลด API calls ที่ไม่จำเป็น

### 4. select_related() ใน Django QuerySets

ลด database queries และ network round-trips ระหว่าง app server กับ DB

---

## 11.4 Server-Side Efficiency

### 1. Webhook-Driven Architecture (ป้องกัน Polling Loop)

### 2. Redis Channel Layer — In-Memory Pub/Sub

Redis in-memory operations ใช้ CPU น้อยกว่า disk-based message queues ประมาณ 10–100x Response time < 1ms แทนที่จะเป็น 10-50ms สำหรับ disk reads

### 3. Room Auto-Cleanup (65-second Timeout)

**ผลกระทบ:** ห้องที่ไม่มีคนปล่อยทิ้งไว้ไม่ได้ใช้ LiveKit room slots บน media server ลดทอน resources ที่ waste

### 4. Container Right-Sizing (cAdvisor Monitoring)

cAdvisor monitoring ให้เห็น actual vs. allocated resources — ป้องกัน over-provisioning

---

## 11.5 การเปรียบเทียบกับ Alternatives

| Feature | Traditional Approach | VivaClub Approach | ประหยัด |
|---------|---------------------|-------------------|---------|
| Profile avatars | CDN photo hosting | Emoji (zero bytes) | ~8 KB per view |
| Notifications | HTTP polling 5s | WebSocket push | ~95% bandwidth |
| Room counts | API polling 1s | Webhook-only | ~99% API calls |
| UI theme | White background | OLED black (Planned) | ~30-50% potential savings |
| Icon assets | PNG at 3 densities | Material vector | ~3 MB bundle size |
| Participant tracking | Both API + webhook | Webhook only | Eliminated duplicate DB writes |

---

## 11.6 Carbon Footprint Considerations

Contabo VPS อยู่ที่สิงคโปร์ (Singapore Data Center):
- **Latency Optimization:** เลือก Singapore เพื่อให้ผู้ใช้ในไทยได้รับประสบการณ์การใช้งานที่ลื่นไหลที่สุด (RTT < 40ms) ลดระยะเวลาที่ CPU/Radio ต้องทำงานรอข้อมูล
- **Energy Mix:** สิงคโปร์มีสัดส่วนพลังงานสะอาด (Renewable) ต่ำกว่ายุโรป แต่การที่ Latency ต่ำช่วยให้ "Time-to-Completion" ของแต่ละ request สั้นลง ซึ่งเป็นการประหยัดพลังงานในเชิงประสิทธิภาพการสื่อสาร

**แผนอนาคต:** เลือก green-certified data center เมื่อ scale up หรือ migrate ไปยัง cloud ที่ใช้ renewable 100% (เช่น AWS Renewable Energy regions, Google Cloud Carbon-Free)

### Efficiency vs. Scale Trade-off

Self-hosted single VPS ที่ใช้งานเต็มประสิทธิภาพ environmentally better กว่า over-provisioned cloud services ที่มี idle resources

---

## 11.7 สรุป Energy Savings Estimates

สรุป measurable savings สำหรับ 1,000 active users ต่อวัน:

| Optimization | Estimated Saving |
|-------------|-----------------|
| OLED Dark Mode | ~35% potential screen energy reduction (Planned V2.0) |
| Emoji avatars | ~80 MB/day bandwidth avoided |
| WebSocket vs polling | ~22 GB/day bandwidth avoided |
| Webhook vs API polling | ~16,800 API requests/day avoided |
| Room auto-cleanup | ~20% LiveKit server idle resource reduced |

**Bottom line:** VivaClub's green design choices ไม่ได้แค่ "ดูดี" แต่มีผลกระทบ real ต่อ battery life ของผู้ใช้ (สำคัญมากสำหรับ users ในช่วงวิกฤต) และ operational cost ของทีม
