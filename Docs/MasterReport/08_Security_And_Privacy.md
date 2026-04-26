# บทที่ 8: ความปลอดภัยและความเป็นส่วนตัว
# Chapter 8: Security and Privacy

---

## สารบัญบท / Chapter Contents

8.1 Authentication System  
8.2 Authorization: Role-Based Access Control  
8.3 Data Privacy: E2EE Clinical Notes  
8.4 Anonymous Identity System (Ghost Profiles)  
8.5 Infrastructure Security  
8.6 Input Validation & Content Safety  
8.7 PDPA Compliance Notes  
8.8 Security Testing & Known Limitations  

---

## 8.1 Authentication System

### JWT Token Architecture

VivaClub ใช้ **JSON Web Tokens (JWT)** ผ่าน `djangorestframework-simplejwt`:

**Token Flow:**

### Custom JWT Claims

Flutter ใช้ claims เหล่านี้เพื่อ route user ไปยัง portal ที่ถูกต้องโดยไม่ต้อง API call เพิ่มเติม

### Email Verification

### Password Security

---

## 8.2 Authorization: Role-Based Access Control

### 3 Roles

| Role | สิทธิ์ | ใช้กับ |
|------|-------|--------|
| `patient` | Default role, เข้าถึง community และ telemed (patient side) | Users ทั่วไป |
| `doctor` | เข้าถึง doctor dashboard, รับ appointments, toggle online | แพทย์ที่ verified |
| `admin` | เข้าถึง admin APIs, ban users, validate reports | ทีมงาน |

### Permission Classes

### SOS Authorization

SOS endpoint มีการตรวจสอบพิเศษ:

**เหตุผล:** SOS queue เป็น shared resource — ถ้าใครก็ได้ trigger ได้ แพทย์จะถูก overwhelmed ด้วย non-emergency cases

### Clinical Data Access Control

---

## 8.3 Data Privacy: E2EE Clinical Notes

### Architecture

OPD Notes และ Personal Notes ใช้ **client-side encryption before upload:**

**Model:**

**ทำไม IV ต้องเก็บแยก:**
- IV ไม่ใช่ secret — safe to store publicly
- IV ต้องไม่ซ้ำกันสำหรับแต่ละ note (unique per encryption)
- ขาด IV → ไม่สามารถ decrypt ได้

### Security Guarantees

| ระดับ | ความสามารถ |
|-------|----------|
| Server ที่ถูก hack | ⚠️ เห็นแค่ ciphertext ไม่สามารถอ่าน clinical content ได้ |
| Database breach | ⚠️ เห็นแค่ ciphertext ไม่มีประโยชน์ถ้าไม่มี key |
| แพทย์คนอื่น | ❌ เห็นแค่ notes ของตัวเองเท่านั้น |
| Admin | ❌ ไม่มีสิทธิ์เข้าถึง clinical notes (queryset returns none) |

### ข้อจำกัด (MVP Limitation)

ใน MVP, encryption key จัดการที่ client แต่ key management ยังไม่ production-grade:
- ยังไม่มี key rotation
- ยังไม่มี key backup mechanism
- V2 ควร implement proper key management (เช่น HSM หรือ KMS)

---

## 8.4 Anonymous Identity System (Ghost Profiles)

### Privacy by Design

Ghost Profile เป็น core privacy mechanism ของ VivaClub:

**ข้อมูลอะไรที่ Community APIs เห็นได้:**

**ข้อมูลที่ LiveKit metadata เห็น:**

User ID ที่แท้จริงไม่มีทางรั่วออกสู่ community layer เลย

### Follow System Privacy

ความสัมพันธ์ follow เป็น Ghost-to-Ghost — ไม่ใช่ User-to-User ทำให้:
- User สามารถ follow โดยไม่เปิดเผย real identity
- Target ghost ไม่รู้ว่า follower คือใคร (รู้แค่ ghost name)

---

## 8.5 Infrastructure Security

### Network Security

**PostgreSQL ไม่เปิด port ออก internet:**

ใช้ Docker network bridge ทำให้ Django เชื่อมต่อ DB ผ่าน service name (`db:5432`) แต่ข้างนอก VPS เข้าไม่ถึง

### Environment Variables Security

Firebase credentials file mount เป็น Docker secret (read-only volume), ไม่ใช่ environment variable เพื่อป้องกัน secrets leaking ใน `docker inspect`

### CORS Configuration

**Note:** MVP ยังใช้ `CORS_ALLOW_ALL_ORIGINS = True` — ควรเปลี่ยนก่อน production launch จริง

---

## 8.6 Input Validation & Content Safety

### Profanity Filter

**ข้อจำกัด:** Wordlist ปัจจุบันเป็นภาษาอังกฤษ ควรเพิ่มภาษาไทยใน V2

### UUID Primary Keys — IDOR Prevention

Insecure Direct Object Reference (IDOR) — ผู้ใช้เข้าถึงข้อมูลคนอื่นโดย guess IDs:

### Rate Limiting (Planned)

MVP ยังไม่มี rate limiting — ควรเพิ่มก่อน production:

---

## 8.7 PDPA Compliance Notes

Thailand's **Personal Data Protection Act (PDPA) B.E. 2562** กำหนดให้:

### Data Collected & Basis

| ข้อมูล | ประเภท | Basis |
|--------|--------|-------|
| Email, username | PII | Contractual necessity (login) |
| Current mood, PHQ-9 score | Sensitive PII | Explicit consent at signup |
| OPD Notes (encrypted) | Sensitive PII (health) | Explicit consent + E2EE |
| Ghost display name | Not PII | N/A |
| Device token | Technical identifier | Legitimate interest |

### Data Minimization

- Community layer ใช้แค่ `ghost_id` — real identity ไม่เปิดเผย
- SOS queue แสดงเฉพาะ `priority_score` แก่แพทย์ ไม่แสดงชื่อจริง
- Clinical notes ถูก encrypt ก่อน store — server ไม่สามารถอ่านได้

### Data Retention (Planned Policy)

---

## 8.8 Security Testing & Known Limitations

### Security Testing Performed

| Test | Method | Result |
|------|--------|--------|
| Authentication bypass | Manual API testing without token | ✅ 401 returned |
| Role escalation | Patient accessing doctor endpoints | ✅ 403 returned |
| IDOR via UUID | Guessing other user's UUIDs | ✅ 404/403 |
| SOS without assessment | POST /clinical/sos/ with LOW mood | ✅ 403 returned |
| SQL injection (basic) | Malformed query params | ✅ DRF/ORM prevents |
| XSS in room title | Script tag in title | ✅ DRF serializer escapes |

### Known Security Limitations (MVP)

| ปัญหา | ความรุนแรง | แผนแก้ไข |
|-------|-----------|----------|
| `CORS_ALLOW_ALL_ORIGINS = True` | Medium | แก้ก่อน public launch |
| No rate limiting on login | Medium | เพิ่มใน V2 |
| JWT access token 30 days (ยาวเกินไป) | Low | ลดเป็น 1-7 days + refresh mechanism |
| Admin credentials ใน .env (not HSM) | Low | ใช้ secrets manager ใน V2 |
| Wordlist filter ภาษาอังกฤษอย่างเดียว | Low | เพิ่มไทยใน V2 |
| No audit log | Low | เพิ่มใน V2 |
