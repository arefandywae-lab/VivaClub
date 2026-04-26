# บทที่ 4: Flutter Mobile Application
# Chapter 4: Flutter Mobile Application

---

## สารบัญบท / Chapter Contents

4.1 ภาพรวม Flutter Architecture  
4.2 State Management: BLoC Pattern  
4.3 Navigation: GoRouter  
4.4 Network Layer: Dio + Interceptors  
4.5 LiveKit Integration  
4.6 Secure Token Storage  
4.7 คลังหน้าจอ — Patient Portal  
4.8 คลังหน้าจอ — Doctor Portal  
4.9 Push Notifications (FCM)  
4.10 UI/UX Design System  

---

## 4.1 ภาพรวม Flutter Architecture

### Technology Stack

| Component | Package | Version | วัตถุประสงค์ |
|-----------|---------|---------|------------|
| Framework | Flutter | 3.x | Cross-platform iOS + Android |
| Language | Dart | 3.x | Type-safe, null-safe |
| State Management | flutter_bloc | 8.x | BLoC pattern |
| Navigation | go_router | 12.x | Declarative routing, deep links |
| HTTP Client | dio | 5.x | REST API + interceptors |
| WebSocket | web_socket_channel | — | Chat + Notifications |
| Media | livekit_client | latest | Audio/Video rooms |
| Push | firebase_messaging | latest | FCM notifications |
| Storage | flutter_secure_storage | 9.x | JWT tokens (encrypted) |
| Design | flutter_screenutil | — | Responsive layout |
| Charts | — | — | Stats visualization |
| Animations | lottie | — | Loading states |

### Project Structure

---

## 4.2 State Management: BLoC Pattern

### สถาปัตยกรรม 3 ชั้น

### BLoC Instances ทั้งหมด

BLoC ทุกตัว inject ที่ root level ใน `main.dart` เพื่อให้ทุก screen ใน app เข้าถึงได้:

### AuthBloc — ตัวอย่าง BLoC Pattern

---

## 4.3 Navigation: GoRouter

### Route Structure

### Auth Guard Logic

---

## 4.4 Network Layer: Dio + Interceptors

### DioClient Singleton

### API Constants

---

## 4.5 LiveKit Integration

### LiveKitRoomService (ChangeNotifier)

Service นี้ manage ทุกอย่างที่เกี่ยวกับ live audio/video:

### Participant Metadata Schema

---

## 4.6 Secure Token Storage

**ทำไมไม่ใช้ SharedPreferences:** SharedPreferences เก็บข้อมูลเป็น plaintext บน disk ใครก็ได้ที่เข้าถึงเครื่อง (rooted/jailbroken) สามารถอ่าน JWT token ได้ `flutter_secure_storage` ใช้ platform-native encryption

---

## 4.7 คลังหน้าจอ — Patient Portal

### Auth Flow

| Screen | File | Features |
|--------|------|---------|
| Splash | `splash_screen.dart` | Token check, auto-redirect |
| Welcome | `welcome_screen.dart` | Login/Register buttons |
| Login | `login_screen.dart` | Username/email + password, forgot password link |
| Register | `signup_screen.dart` | Username, email, password, role selection |
| Email Verify | `email_verify_screen.dart` | 6-digit code input |
| Forgot Password | `forgot_password_screen.dart` | Email input, email sent confirmation |
| Reset Password | `reset_password_screen.dart` | New password + confirm (from deep link) |

### Home / Dashboard

**`dashboard_screen.dart`**

### Community Rooms Flow

| Screen | Key Features |
|--------|-------------|
| `room_list_screen.dart` | Category filter chips, trending/scheduled tabs, search bar, room cards |
| `create_room_screen.dart` | Title, category dropdown, description, tag chips |
| `live_room_screen.dart` | Speakers zone (3-col grid), Listeners zone (4-col grid), host controls, hand-raise, profile cards |

**Live Room Screen — Host Controls:**

### Telemed / Clinical Flow

| Screen | Key Features |
|--------|-------------|
| `telemed_screen.dart` | Hub screen — Assessment CTA, Doctor list, My Appointments |
| `assessment_screen.dart` | 9 questions (PageView), progress bar, 0-3 scale per question |
| `assessment_result_screen.dart` | Risk level card, recommendations, SOS unlock notification |
| `doctor_list_screen.dart` | Doctor cards with ratings, specialty filter, online badge |
| `doctor_profile_screen.dart` | Full profile, time slots, book button |
| `my_appointments_screen.dart` | Upcoming + Past tabs, status badges, Join/Cancel buttons |
| `sos_waiting_screen.dart` | Animated queue position, pulse animation, auto-navigate on ONGOING |
| `video_call_screen.dart` | LiveKit video, chat overlay, camera/mic toggle, call timer, end call |

### PHQ-9 Assessment Screen Flow

### Profile Screen

---

## 4.8 คลังหน้าจอ — Doctor Portal

| Screen | Key Features |
|--------|-------------|
| `doctor_main_screen.dart` | Today's schedule, SOS queue banner (10s polling), shift toggle, stats |
| `doctor_exam_room_screen.dart` | Video call + patient info HUD, OPD note taking, "Complete Session" |
| `doctor_consultation_history_screen.dart` | Past consultation list, search, patient history view |
| `doctor_availability_screen.dart` | Calendar with time slot creation/deletion |
| `doctor_profile_screen.dart` | Edit specialty, bio, license, profile photo |
| `doctor_notification_screen.dart` | Incoming appointment requests, SOS alerts |
| `doctor_patient_detail_screen.dart` | Patient profile, PHQ-9 history, past notes |

### Doctor Dashboard

---

## 4.9 Push Notifications (FCM)

### Setup

**Notification Types:**
| Type | Trigger | Action on tap |
|------|---------|---------------|
| `ghost_room_opened` | Followed ghost opens room | Navigate to live room |
| `hand_raise_accepted` | Host accepts hand raise | Return to room (if left) |
| `appointment_confirmed` | Doctor confirms booking | Open appointments |
| `appointment_reminder` | 15 min before appointment | Open appointments |
| `new_booking_request` | Patient books slot (doctor) | Open doctor dashboard |
| `sos_incoming` | Patient triggers SOS (doctor) | Open SOS queue |

---

## 4.10 UI/UX Design System

### Color Palette

### Responsive Design

### Component Conventions

| Property | Value |
|----------|-------|
| Border Radius | 16–24 dp (rounded) |
| Card Elevation | 0 (flat) / 2 (subtle shadow) |
| Shadow Opacity | 0.05–0.10 |
| Gradient | For feature cards and backgrounds |
| Typography | Inter (Google Fonts) |
| Icon Style | Material Symbols Outlined |
| Dark Mode | OLED black (#000000) — pixels off = no power draw |

### Ghost Avatar Emoji System

Emoji render natively บน iOS/Android โดยไม่ต้องโหลด image — ประหยัด bandwidth และ storage
