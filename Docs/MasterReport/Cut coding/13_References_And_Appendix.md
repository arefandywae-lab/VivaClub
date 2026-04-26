# บทที่ 13: เอกสารอ้างอิงและภาคผนวก
# Chapter 13: References and Appendix

---

## สารบัญบท / Chapter Contents

13.1 เอกสารอ้างอิง (References)  
Appendix A: Environment Variables Reference  
Appendix B: PHQ-9 Scoring Table  
Appendix C: LiveKit Participant Metadata Schema  
Appendix D: Ghost Name Generation  
Appendix E: Test Script Sample Output  
Appendix F: Docker Compose Service Dependency  
Appendix G: API Quick Reference Card  

---

## 13.1 เอกสารอ้างอิง (References)

### ด้านคลินิกและสุขภาพจิต

1. **Kroenke K, Spitzer RL, Williams JBW.** (2001). The PHQ-9: Validity of a Brief Depression Severity Measure. *Journal of General Internal Medicine*, 16(9), 606–613.  
   — Standard PHQ-9 scoring และ cutoff scores ที่ VivaClub ใช้

2. **กรมสุขภาพจิต กระทรวงสาธารณสุข.** (2566). รายงานสถานการณ์สุขภาพจิตในประเทศไทย. กรุงเทพฯ: กรมสุขภาพจิต.

3. **World Health Organization.** (2022). World Mental Health Report: Transforming Mental Health for All. Geneva: WHO.

4. **พระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562 (PDPA).** ราชกิจจานุเบกษา เล่ม 136 ตอนที่ 69 ก.

---

### ด้านเทคโนโลยี

5. **LiveKit Inc.** (2024). LiveKit Documentation — Open Source WebRTC Infrastructure. https://docs.livekit.io/

6. **Django Software Foundation.** (2024). Django REST Framework Documentation. https://www.django-rest-framework.org/

7. **Django Software Foundation.** (2024). Django Channels Documentation. https://channels.readthedocs.io/

8. **Google LLC.** (2024). Flutter Documentation. https://docs.flutter.dev/

9. **Felix Angelov.** (2024). flutter_bloc Package Documentation. https://bloclibrary.dev/

10. **Pezant R., Angelov F.** (2024). GoRouter Navigation Documentation. https://pub.dev/packages/go_router

11. **Internet Engineering Task Force.** (2011). RFC 6455 — The WebSocket Protocol. IETF.

12. **Internet Engineering Task Force.** (2021). RFC 8866 — Session Description Protocol (SDP) — underlying WebRTC signaling.

13. **Caddy Community.** (2024). Caddy Documentation. https://caddyserver.com/docs/

14. **Firebase by Google.** (2024). Firebase Cloud Messaging Documentation. https://firebase.google.com/docs/cloud-messaging

15. **Docker Inc.** (2024). Docker Compose Documentation. https://docs.docker.com/compose/

16. **PostgreSQL Global Development Group.** (2024). PostgreSQL 15 Documentation. https://www.postgresql.org/docs/15/

17. **Redis Ltd.** (2024). Redis 7 Documentation. https://redis.io/docs/

---

## Appendix A: Environment Variables Reference

ตารางนี้แสดง environment variables ทั้งหมดที่ backend ใช้ (**ไม่รวม secret values จริง**)

| Variable | Example Value | Used By | วัตถุประสงค์ |
|----------|--------------|---------|------------|
| `SECRET_KEY` | `django-secret-abc...` | Django | Django cryptographic signing |
| `DEBUG` | `False` | Django | Production mode |
| `ALLOWED_HOSTS` | `vivaclubs.site,www.vivaclubs.site` | Django | Accepted request hosts |
| `DATABASE_URL` | `postgresql://user:pass@db:5432/vivaclub` | Django | PostgreSQL connection |
| `REDIS_URL` | `redis://:password@redis:6379/0` | Django Channels | Redis connection (URL format!) |
| `LIVEKIT_API_URL` | `wss://livekit.vivaclubs.site` | Django | LiveKit server endpoint |
| `LIVEKIT_API_KEY` | `APIxxxxxxxxxxxx` | Django | LiveKit authentication |
| `LIVEKIT_API_SECRET` | `secret_xxxxxxxxxxxx` | Django | LiveKit JWT signing |
| `FIREBASE_CREDENTIALS_PATH` | `/secrets/firebase.json` | Django | FCM push notifications |
| `SMTP_HOST` | `smtp.gmail.com` | Django | Email server |
| `SMTP_PORT` | `587` | Django | Email server port |
| `SMTP_USER` | `noreply@vivaclubs.site` | Django | Email sender |
| `SMTP_PASSWORD` | `app-password-here` | Django | Gmail App Password |
| `CLOUDINARY_CLOUD_NAME` | `vivaclub` | Django | Media storage |
| `CLOUDINARY_API_KEY` | `123456789` | Django | Cloudinary authentication |
| `CLOUDINARY_API_SECRET` | `secret_here` | Django | Cloudinary signing |
| `POSTGRES_DB` | `vivaclub_db` | PostgreSQL | Database name |
| `POSTGRES_USER` | `vivaclub` | PostgreSQL | Database user |
| `POSTGRES_PASSWORD` | `secure_password` | PostgreSQL | Database password |
| `REDIS_PASSWORD` | `redis_password` | Redis | Redis authentication |

**หมายเหตุ:** `REDIS_URL` ต้องใช้ URL string format (`redis://:password@host:port/db`) ไม่ใช่ tuple format — ดู Challenge 1 ในบทที่ 9

---

## Appendix B: PHQ-9 Scoring Table

PHQ-9 (Patient Health Questionnaire-9) เป็น validated clinical tool สำหรับ screening depression VivaClub ใช้ตามมาตรฐาน Kroenke et al. (2001):

### คำถาม PHQ-9 (ภาษาไทย)

ในช่วง **2 สัปดาห์ที่ผ่านมา** คุณมีปัญหาจากสิ่งต่อไปนี้บ่อยแค่ไหน?

| ข้อ | คำถาม |
|-----|-------|
| Q1 | ไม่มีความสนใจหรือความสุขในการทำสิ่งต่างๆ |
| Q2 | รู้สึกหดหู่ใจ สิ้นหวัง หรือท้อแท้ |
| Q3 | นอนหลับยาก นอนหลับไม่สนิท หรือนอนมากเกินไป |
| Q4 | รู้สึกเหนื่อยล้าหรือมีแรงน้อย |
| Q5 | เบื่ออาหารหรือกินมากเกินไป |
| Q6 | รู้สึกว่าตัวเองแย่ เป็นภาระ หรือล้มเหลว |
| Q7 | มีปัญหาในการมีสมาธิ เช่น การอ่านหนังสือหรือดูโทรทัศน์ |
| Q8 | เคลื่อนไหวหรือพูดช้าลงจนคนอื่นสังเกตได้ หรือกระสับกระส่ายมากจนนั่งนิ่งไม่ได้ |
| Q9 | มีความคิดอยากทำร้ายตัวเองหรือคิดว่าตายเสียจะดีกว่า |

### ระดับคะแนน

| ค่า | ความหมาย |
|-----|---------|
| 0 | ไม่เลย |
| 1 | หลายวัน (น้อยกว่าครึ่งของเวลา) |
| 2 | มากกว่าครึ่งของวัน |
| 3 | แทบทุกวัน |

### การแปลผล

| คะแนนรวม | ระดับ | Risk Level ใน VivaClub | การดำเนินการ |
|---------|------|----------------------|------------|
| 0–4 | Minimal depression | `LOW` | Clubhouse community แนะนำ |
| 5–9 | Mild depression | `LOW` | Self-care resources + Community |
| 10–14 | Moderate depression | `MODERATE` | Doctor consultation recommended |
| 15–19 | Moderately severe | `MODERATE` | Doctor consultation strongly advised |
| **20–27** | **Severe depression** | **`SEVERE`** | **SOS button unlocked** |

**ข้อควรทราบ:** PHQ-9 เป็น screening tool ไม่ใช่ diagnostic tool การวินิจฉัยโรคต้องทำโดยผู้เชี่ยวชาญทางคลินิกเท่านั้น

---

## Appendix C: LiveKit Participant Metadata Schema

Metadata ที่ฝังใน LiveKit participant ทุกคน (JSON string):

**ตัวอย่าง:**

**หมายเหตุ:** `identity` ใน LiveKit participant คือ `ghost_id` ด้วย (ไม่ใช่ username) ทำให้ Flutter สามารถ extract ghost_id สำหรับ Follow/Report โดยไม่ต้อง API call เพิ่ม

---

## Appendix D: Ghost Name Generation

`ghost_names.py` ใช้ combination ของ:
- **24 Adjectives:** Happy, Gentle, Brave, Calm, Kind, Wise, Bright, Quiet, Warm, Soft, Bold, Swift, Clear, Deep, Vast, Free, Pure, Safe, True, Wild, Lush, Fair, Cool, Keen
- **150+ Animals:** Panda, Fox, Otter, Deer, Whale, Rabbit, Bear, Cat, Dog, Wolf, Eagle, Owl, Dove, Swan, Tiger, Lion, Frog, Duck, Crane, Moth, Bee, Ant, Elk, Boar, Lynx, Ibis, Mole, Wren, Carp, Kite, ...
- **Number suffix:** 1–999

**ตัวอย่าง output:**
- "Happy Panda #42"
- "Gentle Fox #158"
- "Brave Otter #7"
- "Calm Whale #234"

**Emoji mapping** (100 animals → emoji):

**Total combinations:** 24 × 150 × 999 = **3,596,400 unique ghost names**

---

## Appendix E: Test Script Sample Output

Output จริงจากการรัน `test_patient_journey.py` บน production server:

---

## Appendix F: Docker Compose Service Dependency

**Health Check ใน web service:**

Caddy รอ web service healthy ก่อนรับ traffic ป้องกัน 502 errors ช่วง startup

---

## Appendix G: API Quick Reference Card

**Base:** `https://vivaclubs.site/api`  
**Auth:** `Authorization: Bearer <token>`
