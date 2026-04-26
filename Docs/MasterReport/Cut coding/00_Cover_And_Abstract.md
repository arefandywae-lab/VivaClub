# VivaClub: A Real-Time Mental Health Platform
## Combining Anonymous Community Support and Clinical Telemedicine

---

---

| รายละเอียดโครงการ | |
|---|---|
| ชื่อโครงการ | VivaClub — Mental Health Community & Telemedicine Platform |
| ปีการศึกษา | 2568 (2025–2026) |
| สถาบัน | มหาวิทยาลัยสงขลานครินทร์ วิทยาเขตหาดใหญ่ |
| ภาควิชา | วิศวกรรมคอมพิวเตอร์ |
| วันที่ | 25 เมษายน พ.ศ. 2569 |
| สถานะ MVP | สมบูรณ์ 100% (51/51 ฟีเจอร์) |

---

## ทีมพัฒนา / Development Team

| ชื่อ | รหัสนักศึกษา | บทบาท |
|------|-------------|-------|
| Arefandy Waeouseng | 6610625037 | Full-Stack Lead, Backend Architecture, DevOps |
| Phuritat Lertkitpaisarn | 6610685049 | Flutter Developer, UI/UX, Feature Integration |

---

## บทคัดย่อ (Thai Abstract)

ปัจจุบันปัญหาสุขภาพจิตในประเทศไทยมีแนวโน้มเพิ่มสูงขึ้นอย่างต่อเนื่อง โดยเฉพาะในกลุ่มคนรุ่นใหม่ที่เผชิญกับแรงกดดันทางสังคม การศึกษา และการทำงาน อย่างไรก็ตาม การเข้าถึงบริการสุขภาพจิตยังคงมีอุปสรรคสำคัญ ได้แก่ ความกลัวการถูกตีตรา ค่าใช้จ่ายที่สูง การกระจายของผู้เชี่ยวชาญที่ไม่ทั่วถึง และการขาดช่องทางเชื่อมต่อระหว่างการสนับสนุนจากชุมชนกับการดูแลทางคลินิก

โครงการ VivaClub ถูกพัฒนาขึ้นเพื่อแก้ไขปัญหาเหล่านี้ โดยนำเสนอแพลตฟอร์มที่ผสานสองส่วนสำคัญเข้าด้วยกัน ได้แก่ (1) ระบบชุมชนแบบไม่เปิดเผยตัวตน (Anonymous Community) ที่ใช้ Ghost Profile ช่วยให้ผู้ใช้สามารถแบ่งปันความรู้สึกได้อย่างปลอดภัยผ่านห้องเสียงแบบ Clubhouse และ (2) ระบบเวชกรรมทางไกล (Telemedicine) ที่เชื่อมต่อผู้ใช้กับแพทย์ผู้เชี่ยวชาญผ่านการนัดหมาย การโทรวิดีโอ และระบบ SOS ฉุกเฉิน

ระบบใช้ Django REST Framework สำหรับ Backend, Flutter สำหรับ Mobile Application, LiveKit สำหรับการสื่อสารแบบเรียลไทม์ และ PostgreSQL สำหรับฐานข้อมูล ทั้งหมดถูก Deploy บน VPS ด้วย Docker Compose ผลลัพธ์ที่ได้คือ MVP เวอร์ชัน 1.0 ที่สมบูรณ์ครบถ้วน ผ่านการทดสอบ 51/51 ฟีเจอร์ พร้อมสำหรับการ Deploy จริง

---

## Abstract (English)

Mental health challenges in Thailand are increasing, particularly among young adults facing academic, social, and occupational pressures. However, access to mental health services remains obstructed by social stigma, geographic concentration of specialists, high costs, and the absence of a bridge between peer community support and professional clinical care.

VivaClub is a mobile application that bridges this gap by integrating two core functions: (1) an **Anonymous Community System** using Ghost Profiles that allow users to share experiences safely through Clubhouse-style audio rooms, and (2) a **Telemedicine Portal** that connects users with verified mental health professionals through appointment booking, video consultations, and an emergency SOS triage system.

The platform is built on Django REST Framework (Backend API), Flutter (Cross-platform Mobile), LiveKit (Self-hosted WebRTC media server), PostgreSQL (Relational database), Redis (Real-time channel layer), and Docker Compose (Production deployment on Contabo VPS). The MVP Version 1.0 is 100% complete, with all 51 planned features implemented and verified through automated integration testing.

**Key Contributions:**
- Ghost Profile system for privacy-first mental health community participation
- PHQ-9 automated triage with direct SOS pathway for at-risk users
- Self-hosted LiveKit integration with TURN over TCP for Thai carrier compatibility
- End-to-end encrypted clinical notes architecture
- Complete doctor-side portal for appointment, SOS, and consultation management

---

## วิธีอ่านรายงานนี้ / How to Read This Report

รายงานนี้แบ่งออกเป็น 13 ไฟล์ที่เชื่อมต่อกัน เรียงตามลำดับการอ่านที่แนะนำ:

| ไฟล์ | หัวข้อ | สำหรับผู้อ่าน |
|------|--------|--------------|
| [00] นี่คือไฟล์นี้ | ปกและบทคัดย่อ | ทุกคน |
| [01] Introduction | ที่มา ปัญหา วัตถุประสงค์ | ทุกคน |
| [02] System Architecture | ภาพรวมสถาปัตยกรรมระบบ | นักวิชาการ/ผู้ประเมิน |
| [03] Backend Deep Dive | Django Apps ทั้งหมดอย่างละเอียด | นักพัฒนา/ผู้ประเมินเทคนิค |
| [04] Mobile Application | Flutter App ทั้งหมด | นักพัฒนา/ผู้ประเมินเทคนิค |
| [05] Database Schema | Schema ฐานข้อมูลทุกตาราง | นักพัฒนา/ผู้ประเมินเทคนิค |
| [06] API Reference | Endpoints ทุกตัว | นักพัฒนา |
| [07] Real-Time Systems | LiveKit + WebSocket | นักพัฒนา/ผู้ประเมินเทคนิค |
| [08] Security & Privacy | ความปลอดภัยและความเป็นส่วนตัว | ผู้ประเมิน |
| [09] Challenges & Solutions | ปัญหาที่พบและวิธีแก้ไข | ทุกคน |
| [10] Testing & QA | ผลการทดสอบ | ผู้ประเมิน |
| [11] Green Computing | ความยั่งยืนด้านพลังงาน | ผู้ประเมิน |
| [12] Future Roadmap | แผนพัฒนาต่อไป | ทุกคน |
| [13] References & Appendix | อ้างอิงและภาคผนวก | ทุกคน |

---



## สถานะโครงการ / Project Status

| Module | Features | Progress | Status |
|--------|----------|----------|--------|
| Clubhouse & Community | 15/15 | 100% | COMPLETE ✅ |
| Telemed Patient Side | 12/12 | 100% | COMPLETE ✅ |
| Doctor Side | 10/10 | 100% | COMPLETE ✅ |
| Safety & Infrastructure | 8/8 | 100% | COMPLETE ✅ |
| **TOTAL** | **51/51** | **100%** | **MVP Version 1.0** |

