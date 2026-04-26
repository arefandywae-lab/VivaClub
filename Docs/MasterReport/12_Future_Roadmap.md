# บทที่ 12: แผนพัฒนาต่อไป
# Chapter 12: Future Roadmap

---

## สารบัญบท / Chapter Contents

12.1 MVP Retrospective — สิ่งที่สร้างและสิ่งที่ตัดออก  
12.2 Version 2.0: Financial Infrastructure  
12.3 Version 2.0: Medical Professionalism  
12.4 Version 2.0: AI Integration  
12.5 Version 2.0: Community Growth  
12.6 Version 3.0: Scale and B2B  
12.7 Priority Matrix  

---

## 12.1 MVP Retrospective

### สิ่งที่สร้างสำเร็จ (51/51 features)

### สิ่งที่ตัดออกจาก MVP (Deferred Features)

| Feature | เหตุผลที่ตัด | Version ที่จะทำ |
|---------|------------|----------------|
| Viva Coins Wallet | ต้องการ payment gateway integration | V2.0 |
| Real payment (Stripe/Omise) | Complex compliance + testing | V2.0 |
| Subscription plans (Viva Care) | ต้องการ billing engine ก่อน | V2.0 |
| OCR doctor license verification | AI/ML feature — ออกแบบ DB ก่อน | V2.0 |
| AI triage assistant (LLM) | LLM cost + safety considerations | V2.0 |
| Screen sharing in video calls | LiveKit supports it — UI ยังไม่ทำ | V2.0 |
| Referral program | ต้องการ wallet ก่อน | V2.0 |
| Student verification | Pending university API | V3.0 |
| Analytics dashboard (B2B) | Enterprise feature — V3 scope | V3.0 |

---

## 12.2 Version 2.0: Financial Infrastructure

**เป้าหมาย:** เปิด monetization ทำให้ platform self-sustaining

### Viva Coins Wallet System

**Models ที่ต้องเพิ่ม:**

### Pay-per-Minute Billing

---

## 12.3 Version 2.0: Medical Professionalism

### OCR License Verification

**เปลี่ยนจาก manual admin verification เป็น automated flow**

### E-Prescription System

**ความท้าทาย:** ต้องร่วมมือกับ เภสัชกรรม ที่มีใบอนุญาต และ comply กับ กฎหมายยา พ.ร.บ. ยา

### Deepened Patient History

---

## 12.4 Version 2.0: AI Integration

### Conversational PHQ-9 Assessment

แทนที่จะตอบ 9 ข้อ form — คุยกับ AI chatbot:

**Model ที่จะใช้:** Claude API (Anthropic) หรือ OpenAI GPT ด้วย system prompt ที่ออกแบบโดยจิตแพทย์

### Crisis Detection

**Privacy consideration:** ต้อง explicit consent — users เลือก opt-in เท่านั้น

### AI Triage Assistant

---

## 12.5 Version 2.0: Community Growth

### "Clubs" — Persistent Support Groups

### Paid Therapy Events (Ticketing)

### Screen Sharing (LiveKit Feature — UI Pending)

LiveKit รองรับ screen sharing ตั้งแต่ต้น แต่ Flutter UI ยังไม่ implement:

**Use cases:** Doctor แสดง psychoeducation slides, แชร์ mood tracking app, demonstrate relaxation techniques

---

## 12.6 Version 3.0: Scale and B2B

### LiveKit Multi-Node Cluster

**Target:** 10,000 concurrent audio participants

### VivaCare B2B — Corporate Mental Health

**Privacy:** Aggregate data เท่านั้น — ไม่สามารถ identify individual employees

### PostgreSQL Read Replicas

---

## 12.7 Priority Matrix

| Feature | Impact | Complexity | Weeks | Priority |
|---------|--------|-----------|-------|---------|
| Viva Coins Wallet | 🔴 High | 🔴 High | 4-6 | V2 Sprint 1 |
| Omise Payment Integration | 🔴 High | 🟡 Medium | 2-3 | V2 Sprint 1 |
| OCR Doctor Verification | 🟡 Medium | 🔴 High | 3-4 | V2 Sprint 2 |
| Subscription Plans | 🔴 High | 🟡 Medium | 2 | V2 Sprint 2 |
| Screen Sharing UI | 🟡 Medium | 🟢 Low | 1 | V2 Sprint 1 |
| Conversational PHQ-9 (AI) | 🟡 Medium | 🔴 High | 4-5 | V2 Sprint 3 |
| Crisis Detection | 🔴 High | 🔴 High | 5-6 | V2 Sprint 3 |
| Clubs Feature | 🟡 Medium | 🟡 Medium | 3-4 | V2 Sprint 2 |
| Paid Events/Ticketing | 🟢 Low | 🟡 Medium | 2-3 | V2 Sprint 4 |
| E-Prescription | 🟢 Low | 🔴 High | 8-10 | V3 |
| LiveKit Cluster | 🟢 Low | 🔴 High | 6-8 | V3 |
| VivaCare B2B | 🔴 High | 🔴 High | 10-12 | V3 |
| PostgreSQL Replicas | 🟢 Low | 🟡 Medium | 2 | V3 |

### V2.0 Sprint Plan (Recommended Order)
