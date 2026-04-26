# VivaClub — Final Presentation
**Telemedicine & Community Sharing Space Application**
**Presented By:** Arefandy Waeouseng, Phuritat Lertkitpaisarn

---

# Slide 1: ตอน Mid-term เราอยู่ตรงไหน?

## Recap ใน 30 วินาที

| หัวข้อ | Mid-term | ตอนนี้ |
|--------|----------|--------|
| Clubhouse (Audio Room) | ✅ มีแล้ว | ✅ Production |
| Ghost Profile | ✅ มีแล้ว | ✅ Production |
| SOS System | 🟡 Concept เท่านั้น | ✅ ทำงานจริง |
| Doctor Side | ❌ ยังไม่มี | ✅ ครบ 10/10 feature |
| Deployment | Railway (free tier) | ✅ VPS จริง vivaclubs.site |
| Features รวม | ~20/51 | **51/51 (100%)** |

### Bottom line
> ตอน Mid-term เราพิสูจน์ว่า **concept ใช้ได้**
> ตอนนี้เราพิสูจน์ว่า **มันทำงานในโลกจริง**

---

# Slide 1.5: เราสร้างจากปัญหาจริง ไม่ใช่จากการเดา

## แนวทาง: Qualitative User Interview

เราไม่ได้ทำแบบสอบถาม Google Form — เราคุยตรงๆ กับคนที่เคยใช้แอปสุขภาพจิตในชีวิตจริง

```
คุยตรงๆ กับผู้ใช้ Alljit
      ↓
ฟัง pain point — ไม่ตัดสิน ไม่นำ
      ↓
เอาปัญหานั้นไปสร้าง feature ทันที
      ↓
ให้คนกลุ่มเดิมมาลองใช้ VivaClub
      ↓
ฟัง feedback รอบสอง — แก้ต่อ
```

**ทำไมไม่ใช้ Google Form?**
Form ถามได้แค่ "คะแนน 1-5" แต่เราอยากรู้ว่า *"รู้สึกยังไงตอนที่เปิดแอปแล้วคนรู้จักเห็น?"*
คำตอบแบบนั้นได้จากการคุยเท่านั้น

---

## สิ่งที่ได้ยิน → สิ่งที่เราสร้าง

| สิ่งที่ผู้ใช้พูด (Alljit) | ปัญหาจริงคืออะไร | VivaClub ตอบยังไง |
|--------------------------|-----------------|------------------|
| *"กลัวเพื่อนเห็นว่าเราใช้แอปพวกนี้"* | Stigma — ไม่มี anonymity | Ghost Profile ชื่อสุ่ม ไม่มีรูปจริง |
| *"คิวรอหมอเป็นอาทิตย์ แต่ตอนนั้นเครียดมาก"* | Emergency ไม่มีช่องทางด่วน | SOS Queue — หมอเวรรับทันที |
| *"มีแต่บทความ รู้สึกคุยกับกำแพง"* | Passive — ไม่มี real interaction | Audio Room — พูดคุยสดกับคนอื่นได้ |
| *"ไม่รู้ว่าหมอที่แอปเลือกให้น่าเชื่อถือไหม"* | Transparency ต่ำ | Verified badge + rating + รีวิวจริง |
| *"กังวลว่าที่คุยกับหมอจะถูกเก็บไว้"* | ความไว้ใจเรื่อง privacy | E2EE — server ไม่เคยเห็น plaintext |

---

## หลังให้ใช้ VivaClub — สิ่งที่ได้ยินรอบสอง

> *"ชื่อที่สุ่มมาให้มันทำให้รู้สึกว่ากล้าเข้าใช้ขึ้นมาก ไม่ต้องคิดเองด้วย"*

> *"ปุ่ม SOS มันทำให้รู้สึกว่ามีคนรอรับอยู่จริงๆ ต่างจากที่เคยใช้มาก"*

> *"UI กดแล้วรู้ว่าจะไปไหน ไม่ต้องงมหา"*

**สิ่งที่สำคัญ:** คนกลุ่มเดิมที่บอกว่า Alljit แก้ปัญหาไม่ได้ — บอกว่า VivaClub แก้ได้

---

# Slide 2: สิ่งที่เพิ่มหลัง Mid-term

## ก้อนที่ 1 — Doctor Side (ไม่มีเลยตอน Mid)

```
❌ Mid-term: หมอ = แค่ account ในฐานข้อมูล ไม่มี UI ไม่มี flow
✅ ตอนนี้:
```

| Feature | รายละเอียด |
|---------|-----------|
| Doctor Login | Portal แยก, JWT role = `doctor` |
| Dashboard | จัดการ queue, เห็น SOS alert real-time |
| Shift Toggle | กด Online/Offline → รับ SOS หรือไม่รับ |
| Exam Room | Video call + Patient HUD (ชื่อ ghost, คะแนน PHQ-9, ประวัติ) |
| OPD Notes | บันทึกผลการรักษา — **เข้ารหัส E2EE ก่อน upload** |
| SOS Accept | กด Accept → redirect ไปห้อง video กับคนไข้ทันที |

---

## ก้อนที่ 2 — Infrastructure จริง

```
Before:  Railway free tier → restart ทุก 30 นาที, ไม่มี custom domain
After:   Contabo VPS (เยอรมนี) → 24/7, HTTPS, custom domain
```

**Stack ที่เพิ่ม:**

```
Docker Compose ─── web (Django)
                ├── db (PostgreSQL 15)
                ├── redis (Channel Layer)
                ├── livekit (Self-hosted SFU)
                ├── caddy (Reverse Proxy + TLS อัตโนมัติ)
                └── cadvisor (Monitoring)
```

- **Caddy** ออก Let's Encrypt certificate อัตโนมัติ — ไม่ต้องทำ manual
- **Django Channels** → WebSocket real-time notifications (ไม่ต้อง polling)
- **FCM** → Push notification บน iOS และ Android

---

## ก้อนที่ 3 — Security ที่ครบถ้วน

| Feature | รายละเอียด |
|---------|-----------|
| Email Verification | สมัครแล้วต้องยืนยัน 6-digit OTP ทาง email |
| Password Reset | ส่ง secure link ผ่าน SMTP (ไม่ใช่ SMS — ป้องกัน SIM swap) |
| E2EE Clinical Notes | AES-256 encrypt ที่ client, server เห็นแค่ ciphertext |
| UUID Primary Keys | ป้องกัน IDOR (ไม่สามารถ guess `/appointments/1/`) |
| Keychain Storage | JWT เก็บใน iOS Keychain / Android Keystore |

---

# Slide 3: ปัญหาใหญ่สุด — TURN / MTU Blackhole

## "วันที่เสียงทะลุ WiFi แต่ตายบน AIS, True, DTAC"

### อาการ

```
✅ WiFi บ้าน  → เสียงปกติ คุณภาพดี
❌ AIS 4G     → เข้าห้องได้ แต่ไม่ได้ยินเสียงอะไรเลย
❌ True Move  → เหมือนกัน — เงียบสนิท ไม่มี error
❌ DTAC       → เหมือนกัน
```

ไม่มี error message, ไม่มี crash — แค่เงียบ

---

### สาเหตุ: Path MTU Blackhole

LiveKit ส่งเสียงด้วย UDP
UDP packet ขนาด 1500 bytes (default MTU)

WiFi Router   → รับได้ → เสียงผ่าน ✅

AIS Carrier   → MTU ต่ำกว่า 1500 → packet ใหญ่เกินไป
               → Carrier DROP packet ทิ้ง
               → UDP ไม่มี retransmit
               → เงียบสนิท ❌


**ทำไม debug ยาก:**
- UDP ไม่มี acknowledgment — ไม่รู้ว่า packet หาย
- Flutter ไม่ throw exception — LiveKit บอกว่า "connected"
- ทดสอบบน WiFi ผ่านตลอด — ไม่รู้ว่า carrier เป็นปัญหา

---

### วิธีแก้: TURN over TCP Port 443


Before (UDP ตรง):
  Phone ──── UDP 7882 ────→ LiveKit Server
              ↑ carrier DROP

After (TURN Relay TCP):
  Phone ──── TCP 443 ────→ Caddy ──→ TURN Server ──→ LiveKit
              ↑ carrier ไม่กล้าบล็อก HTTPS port


**ทำไม Port 443 ถึงรอด?**
- Port 443 = HTTPS — carrier บล็อกไม่ได้ (internet จะพัง)
- TURN relay ห่อ UDP ไว้ใน TCP packet
- packet เล็กลง → ไม่ติด MTU limit

**Config ที่แก้:**

livekit.yaml

rtc:
  turn_enabled: true
  turn_servers:
    - host: livekit.vivaclubs.site
      port: 443
      protocol: tcp
  force_turn: false        # fallback อัตโนมัติ ไม่บังคับ
  ice_candidate_filter:
    kinds: [host, srflx, relay]


**ผลลัพธ์:**

| Network | ก่อนแก้ | หลังแก้ |
|---------|---------|---------|
| WiFi | ✅ | ✅ |
| AIS 4G | ❌ เงียบ | ✅ เสียงชัด |
| True Move | ❌ เงียบ | ✅ เสียงชัด |
| DTAC | ❌ เงียบ | ✅ เสียงชัด |
| 3G (สัญญาณอ่อน) | ❌ | ⚠️ พอใช้ได้ |

---

### Key Takeaway

> **"WebRTC ไม่ได้แปลว่า real-world works"**
> มันแปลว่าต้องออกแบบ fallback path ด้วย
> เพราะ internet ในโลกจริงไม่ได้ clean อย่างที่ spec บอก

---

# Slide 4: ปัญหาอื่นที่น่าสนใจ

## Bug 1: Bot เสียงกระตุก

**อาการ:** Bot ที่ generate เสียงแบบ programmatic — กระตุกทุก ~30 วินาที

**สาเหตุ:**

# ❌ วิธีเดิม — asyncio.sleep drift
while True:
    play_audio_chunk()
    await asyncio.sleep(0.02)  # ควรเป็น 20ms แต่จริงๆ drift ออกไปเรื่อยๆ
# หลัง 30 วินาที drift สะสม → เสียงสะดุด


**แก้ด้วย monotonic clock:**

# ✅ วิธีใหม่ — drift-corrected timing
next_time = time.monotonic()
while True:
    play_audio_chunk()
    next_time += 0.02
    sleep_duration = next_time - time.monotonic()
    if sleep_duration > 0:
        await asyncio.sleep(sleep_duration)
# drift ถูก correct ทุก loop → เสียงราบเรียบ


---

## Bug 2: SOS Screen ค้างตลอด

**อาการ:** คนไข้กด SOS รอหมอ — หมอรับแล้ว แต่คนไข้ยังเห็น "กำลังรอ..."

**สาเหตุ:** Flutter ไม่รู้ว่า status เปลี่ยน — ไม่มี listener

**แก้:**

// เพิ่ม polling ทุก 5 วินาที
Timer.periodic(const Duration(seconds: 5), (timer) async {
  final position = await repository.getMySOSPosition();
  if (position.status == 'ONGOING') {
    timer.cancel();
    // navigate ไปหน้า video call อัตโนมัติ
    context.go('/video-call/${position.roomToken}');
  }
});


---

## Bug 3: Follow Ghost ในห้อง พัง

**อาการ:** กด Follow คนอื่นในห้อง LiveKit ไม่ได้ — API บอก ghost ไม่มีอยู่

**สาเหตุ:** LiveKit ส่งแค่ `username` ไม่มี `ghost_id` → Flutter ต้อง extra API call → race condition

**แก้:** ฝัง `ghost_id` ใน LiveKit participant metadata ตั้งแต่ต้น:

{
  "ghost_id": "550e8400-...",
  "display_name": "Happy Panda #42",
  "role": "listener"
}

Flutter อ่าน metadata ได้เลย ไม่ต้อง API call เพิ่ม

---

# Slide 5: ตัวเลขที่วัดได้

## Stress Test Results


╔══════════════════════════════════════════════╗
║           STRESS TEST — vivaclubs.site        ║
╠══════════════════════════════════════════════╣
║  20 users สมัครพร้อมกัน    →  20/20  ✅     ║
║  15 หมอสร้าง slot พร้อมกัน →  15/15  ✅     ║
║  20 คน book slot เดียวกัน  →   1/20  ✅     ║
║     (atomic lock — คนที่เหลือได้ 400)        ║
║                                               ║
║  API Response Time: < 200ms avg              ║
║  Database Integrity: 100% maintained         ║
╚══════════════════════════════════════════════╝


## ขนาดโปรเจกต์

| ส่วน | บรรทัด |
|------|--------|
| Python (Backend — Django) | 72,141 |
| Dart (Flutter App) | 14,747 |
| **รวม** | **86,888 บรรทัด** |

## API Coverage

**35 endpoints — pass rate 100%**

---

# Slide 6: Green Computing

## "แอปสุขภาพจิต ควรกินแบตน้อยที่สุด"

เหตุผล: user ที่อยู่ในวิกฤตจิตใจ มักใช้งานกลางดึก แบตเตอรี่เหลือน้อย — ถ้าแอปกินแบตเยอะ อาจตัดสายความช่วยเหลือออก

### สิ่งที่ทำ

| เทคนิค | ประหยัดอะไร |
|--------|------------|
| **OLED True Black** (#000000) | screen energy ลด 30–50% |
| **Emoji แทน Profile Photo** | 0 bytes ต่อ avatar (photo = 8 KB) |
| **WebSocket แทน Polling** | bandwidth ลด ~22 GB/วัน (1,000 users) |
| **Webhook แทน API polling** | API calls ลด 99% |
| **BLoC `buildWhen`** | UI rebuild เฉพาะ widget ที่จำเป็น |

### Bottom Line
> Green ไม่ใช่แค่ดูดี — มันทำให้ **user เข้าถึงความช่วยเหลือได้นานขึ้น**

---

# Slide 7: What's Next — V2.0

## 3 สิ่งที่อยากทำต่อ (Priority Order)

### 1. Viva Coins Wallet (Sprint 1)
```
User ซื้อ Coins → จ่ายผ่าน Omise (Thai payment)
Book หมอ → ตัด Coins อัตโนมัติ
หมอถอนเงิน → 80% ของ Coins ที่ได้
```

### 2. AI Triage Assistant (Sprint 3)
```
User: "ฉันมีอาการ panic attack บ่อยๆ"
AI:   "แนะนำปรึกษา: จิตแพทย์ (ถ้าต้องการยา) หรือ
       นักจิตวิทยา (CBT therapy)"
       → แสดงรายชื่อหมอที่เหมาะสม
```
Model ที่จะใช้: **Claude API (Anthropic)**

### 3. OCR License Verification (Sprint 2)
```
ตอนนี้: Admin verify หมอ manually
V2:     อัพโหลดรูปใบประกอบวิชาชีพ
        → OCR extract เลขใบอนุญาต
        → ตรวจกับ Thai Medical Council API อัตโนมัติ
```

---

# Slide 8: Closing

## สิ่งที่ได้เรียนรู้จริงๆ

### Technical
> "Production ไม่ใช่แค่ code ที่ run — มันคือ code ที่ run บน network จริง, device จริง, และ carrier ไทยจริง"

### Process
- ปัญหา TURN สอนว่า **"ทดสอบบน localhost ไม่พอ"** — ต้องทดบน mobile network จริง
- Integration test ให้ความมั่นใจมากกว่า unit test สำหรับ API-driven app
- Deploy เร็ว fail เร็ว แก้เร็ว — production ตั้งแต่ต้นทำให้เจอ bug จริง

### ผลสุดท้าย
```
51 features ✅
35 API endpoints ✅
Production ที่ vivaclubs.site ✅
Tested on AIS, True, DTAC ✅
```

---

*VivaClub — Mental Health Platform | Final Presentation 2026*
*Arefandy Waeouseng 6610625037 | Phuritat Lertkitpaisarn 6610685049*
