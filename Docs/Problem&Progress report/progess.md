# VivaClub Development Progress

**Last Updated:** 2026-03-22  
**Overall Completion:** 42% (22/53 features)

---

## 📊 Progress Overview

| Category | Complete | Total | % | Status |
|----------|----------|-------|---|--------|
| **Clubhouse & Community** | 15 | 15 | 100% | ✅ COMPLETE |
| **Telemed (Patient)** | 3 | 12 | 25% | 🟡 Backend Ready |
| **Doctor Side** | 1 | 10 | 10% | 🟡 Backend Foundation |
| **Safety & Moderation** | 5 | 8 | 62% | 🟡 In Progress |
| **Infrastructure & Security** | 4 | 6 | 66% | 🟡 Optimizing for Thai Mobile |
| **Monetization** | 0 | 8 | 0% | 🔴 Not Started |
| **TOTAL** | **25** | **55** | **45%** | 🟡 In Progress |


---

## 🎙️ CLUBHOUSE FEATURES (100% Complete ✅)

### ✅ Completed (15/15)

#### Core Features
- [x] **Ghost Profile System** (Priority: 🔴 Critical)
  - Random animal names (200+ variations)
  - Emoji avatars (200+ emojis)
  - Preset-only profiles (no custom uploads)
  - Content safety built-in
  
- [x] **Audio Rooms** (Priority: 🔴 Critical)
  - Create room
  - Join room
  - Leave room
  - LiveKit integration
  - Real-time audio streaming
  
- [x] **Room Roles & Permissions** (Priority: 🔴 Critical)
  - Host role
  - Speaker role
  - Listener role
  - Role-based permissions
  
- [x] **Room Interactions** (Priority: 🟡 High)
  - Hand raise
  - Invite speaker (Host only)
  - Mute/Unmute
  - Mic indicator on avatar
  
- [x] **Room Discovery** (Priority: 🟡 High)
  - Room list with live updates
  - 6 Categories (Anxiety, Burnout, Relationships, Depression, Sleep, General)
  - Category filtering
  - Countdown timer
  
- [x] **Navigation & UX** (Priority: 🟡 High)
  - Bottom navigation bar
  - Persistent audio overlay
  - Minimize room feature
  - Modern, clean UI
  - **NEW:** Drag-and-drop to invite speakers (Host UI)
  - **NEW:** Profile ID Card Bottom Sheet in Live Room

---

### ❌ Missing Clubhouse Features (4/15)

> **Phase 3: Trust Score & Safety ✅ COMPLETE** (2026-02-27)
> - `UserTrustScore` and `RoomReport` Django models + migrations
> - API: `POST /api/community/reports/`, `GET /api/community/reports/`, `PATCH /api/community/reports/{id}/validate/`
> - API: `GET /api/community/trust-score/me/`
> - Flutter: Report Dialog in Live Room (tap listener/speaker → Report)
> - Flutter: Trust Score badge displayed in Profile Quick Stats

> **Phase 4: Remaining Clubhouse ✅ COMPLETE** (2026-02-27)
> - Room Search (`?search=keyword`), Trending Sort (`?sort=trending`), Scheduled Sort (`?sort=scheduled`)
> - Profanity Filter on room title creation
> - `bio` field on `GhostProfile` model — PATCH `/api/community/ghosts/me/`
> - `BlockedUser` model + `POST/GET/DELETE /api/community/blocks/` API
> - Migration 0008: `bio`, `BlockedUser`
> - Flutter: Search bar + 🕐 Recent / 🔥 Trending / 📅 Scheduled sort chips in Room List
> - Flutter: 📤 Share Link button in Live Room header (opens native share sheet)
> - Flutter: ✍️ Bio Edit bottom sheet on Profile screen (tap bio card → edit → PATCH API)
> - Flutter: Action Row on Profile (👥 Following, 🚫 Blocked, 🔒 Privacy)
> - Flutter: BlockedUsersScreen — list blocked ghosts, confirm + Unblock
> - Flutter: Anonymous Subscription — Follow/Unfollow ghosts, Following Feed tab, Following List screen
> - Flutter: In-app Notification Center (bell icon → notifications list)

#### 1. Anonymous Subscription System ✅ COMPLETE

- [x] Follow/Unfollow ghost profiles
- [x] Follower count display
- [x] Following list screen (`/following`)
- [x] Push notification when followed ghost opens room
- [x] Following feed tab
- [x] Notification center

---

#### 2. Enhanced Room Discovery ✅ COMPLETE

- [x] Trending rooms (sorted by listener count) — `?sort=trending`
- [x] Scheduled rooms — `?sort=scheduled`
- [x] Search by keyword — `?search=keyword`
- [x] Room description field — already in model
- [x] Room tags — already in model

---

#### 3. Room Interaction Enhancements ✅ COMPLETE

- [x] Backend Endpoints (Hand Raise, Mute, Kick)
- [x] Share room link — native Share Sheet in Live Room header

---

#### 4. Profile Features ✅ COMPLETE

- [x] Bio/About section — editable with bottom sheet dialog
- [x] Following/Blocked navigation from Profile action row
- [x] Follower count on GhostProfile

---

#### 5. Safety — Block User ✅ COMPLETE

- [x] `BlockedUser` model + migration
- [x] `POST /api/community/blocks/` — block a user
- [x] `DELETE /api/community/blocks/{id}/unblock/` — unblock
- [x] `GET /api/community/blocks/` — list blocked users with ghost details
- [x] `BlockedUsersScreen` in Flutter — list + confirm unblock dialog

---

#### ❌ Still TODO: Push Notifications (FCM)

---

#### 3. Room Interaction Enhancements (Priority: 🟢 Medium)
**Impact:** Better engagement, fun factor  
**Estimated Time:** 3-5 days

- [x] **Backend Endpoints** (Hand Raise, Mute, Kick) ✅
- [x] Share room link (Native share sheet) ✅

**Database:** Minimal changes  
**APIs Needed:** Done ✅
**Frontend:** Done ✅

---

#### 5. Push Notifications (Priority: 🟡 High)
**Impact:** Re-engagement, retention  
**Estimated Time:** 3-5 days

- [ ] Firebase Cloud Messaging (FCM) setup
- [ ] Notification when followed ghost opens room
- [ ] Notification when hand raise accepted
- [ ] In-app notification center (UI only — already partially done)

---

## 🏥 TELEMED FEATURES - Patient Side (8% Complete)

### ✅ Completed (1/12)

- [x] **Telemed Placeholder Screen** (Priority: 🔵 Low)
  - Basic UI only, no functionality

---

### ❌ Missing Telemed Features (11/12)

#### 1. PHQ-9 Assessment (Priority: 🔴 **CRITICAL**)
**Impact:** Foundation for SOS system  
**Estimated Time:** 1 week

- [x] PHQ-9 questionnaire (Backend Model & API)
- [x] Score calculation algorithm (Backend Logic)
- [x] Severity level classification (Backend Logic)
- [ ] **[PRIORITY: DAY 1]** PHQ-9 UI Flow in Flutter
- [ ] Assessment history UI
- [ ] Unlock SOS button (Logic exists, needs UI)
- [ ] Daily check-in reminder

**Database:** New `PHQ9Assessment` model  
**APIs Needed:** 3 endpoints  
**Frontend:** Assessment flow UI

---

#### 2. SOS System (Priority: 🔴 **CRITICAL**)
**Impact:** Life-saving feature, social impact  
**Estimated Time:** 1 week

- [x] **[PRIORITY: DAY 2]** SOS button (Backend & Logic)
- [x] **[PRIORITY: DAY 2]** Priority queue with Position Status API
- [ ] [PRIORITY: DAY 2] SOS button UI
- [ ] Free 15-min consultation
- [ ] Cooldown system (30 days / 1 per month)
- [ ] SOS call history
- [ ] Emergency escalation

**Database:** New `SOSCall` model  
**APIs Needed:** 4 endpoints  
**Frontend:** SOS UI + Video call

#### 3. Doctor List & Profiles (Priority: 🟡 High)
**Impact:** Core telemed functionality  
**Estimated Time:** 1 week

- [x] [PRIORITY: DAY 1] Browse doctors list
- [x] [PRIORITY: DAY 1] Filter by specialty (Psychiatrist, Psychologist, Counselor)
- [x] [PRIORITY: DAY 1] Doctor profile page
- [x] Official badge display
- [x] Doctor availability status
- [x] Doctor ratings/reviews (Backend Aggregation)
- [x] Search doctors API

**Database:** `ProfessionalProfile` model (Verified)  
**APIs Needed:** Done (Verified)  
**Frontend:** Doctor list + profile screens (MISSING)

---

#### 4. Appointment Booking (Priority: 🟡 High)
**Impact:** Core telemed functionality  
**Estimated Time:** 1 week

- [x] View doctor's available time slots (Backend API)
- [x] Book appointment / Reserve (Backend API & Transaction logic)
- [x] 100% deposit payment (Logic simulated in confirm API)
- [ ] **[PRIORITY: DAY 2]** Appointment Booking UI flow in Flutter
- [x] Cancellation (24h refund policy API)
- [x] Appointment reminders (Backend Background Task)
- [x] Appointment history API
- [ ] Reschedule appointment

**Database:** New `Appointment` model  
**APIs Needed:** 6 endpoints  
**Frontend:** Booking flow UI

---

#### 5. Video Call - Patient Side (Priority: 🟡 High)
**Impact:** Core telemed functionality  
**Estimated Time:** 1 week

- [ ] **[PRIORITY: DAY 3]** Video call interface
- [ ] Camera on/off
- [ ] Mic on/off
- [ ] Screen share (optional)
- [ ] Call timer
- [ ] **[CUT]** Pay-per-minute billing
- [ ] End call
- [ ] Call quality indicator

**Integration:** LiveKit video  
**APIs Needed:** 3 endpoints  
**Frontend:** Video call UI

---

#### 6. Chat with Doctor (Priority: 🟢 Medium)
**Impact:** Better communication  
**Estimated Time:** 3-5 days

- [ ] Text chat with doctor
- [ ] Message history
- [ ] File/image upload
- [ ] Typing indicator
- [ ] Read receipts
- [ ] Unread count

**Database:** New `Message` model  
**APIs Needed:** 4 endpoints  
**Frontend:** Chat UI

---

#### 7. Wallet & Viva Coins (Priority: 🟡 High)
**Impact:** Monetization foundation  
**Estimated Time:** 1 week

- [ ] **[CUT]** Viva Coins balance display
- [ ] **[CUT]** Top-up interface
- [ ] **[CUT]** Payment gateway integration (Stripe/Omise)
- [ ] **[CUT]** Transaction history
- [ ] **[CUT]** Refund management
- [ ] **[CUT]** Low balance warning

**Database:** New `Wallet`, `Transaction` models  
**APIs Needed:** 6 endpoints  
**Frontend:** Wallet screens

---

#### 8. Subscription - Viva Care (Priority: 🟢 Medium)
**Impact:** Recurring revenue  
**Estimated Time:** 1 week

- [ ] **[CUT]** Subscription plans display
- [ ] **[CUT]** Subscribe/Unsubscribe
- [ ] **[CUT]** Free credits allocation
- [ ] **[CUT]** Priority queue badge
- [ ] **[CUT]** Exclusive content access
- [ ] **[CUT]** Auto-renewal management

**Database:** New `Subscription` model  
**APIs Needed:** 4 endpoints  
**Frontend:** Subscription screens

---

#### 9. Referral Program (Priority: 🔵 Low)
**Impact:** User acquisition  
**Estimated Time:** 3-5 days

- [ ] **[CUT]** Referral code generation
- [ ] **[CUT]** Share referral link
- [ ] **[CUT]** Track referrals
- [ ] **[CUT]** Referral rewards (Coins)
- [ ] **[CUT]** Leaderboard (optional)

---

#### 10. Medical Records (Priority: 🔵 Low)
**Impact:** User value  
**Estimated Time:** 3-5 days

- [ ] **[CUT]** Consultation history
- [ ] **[CUT]** Doctor notes (if shared)
- [ ] **[CUT]** Prescriptions
- [ ] **[CUT]** Download records (PDF)

---

#### 11. Emergency Contacts (Priority: 🟢 Medium)
**Impact:** Safety  
**Estimated Time:** 2-3 days

- [ ] **[CUT]** Add emergency contacts
- [ ] **[CUT]** Auto-notify on SOS call
- [ ] **[CUT]** Crisis hotline numbers display
- [ ] **[CUT]** Quick dial emergency

---

## 👨‍⚕️ DOCTOR SIDE FEATURES (0% Complete)

### ❌ All Missing (10/10)

#### 1. Doctor Login & Auth (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 1 week

- [ ] **[PRIORITY: DAY 2]** Separate doctor login
- [ ] Doctor registration
- [ ] License verification upload
- [ ] Admin approval workflow
- [ ] Doctor onboarding

---

#### 2. Doctor Dashboard (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 1 week

- [ ] **[PRIORITY: DAY 2]** Today's appointments
- [ ] Upcoming appointments
- [ ] **[PRIORITY: DAY 2]** SOS queue (standby doctors)
- [ ] Earnings summary
- [ ] Quick stats (patients seen, hours worked)
- [ ] Performance metrics

---

#### 3. Shift Management (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 1 week

- [ ] Check-in/Check-out system
- [ ] Shift schedule
- [ ] Standby status toggle
- [ ] Heartbeat monitoring (prevent idle)
- [ ] Standby allowance tracking
- [ ] Shift history

**Database:** New `DoctorShift`, `DoctorHeartbeat` models

---

#### 4. Patient List (Priority: 🟡 High)
**Estimated Time:** 3-5 days

- [ ] View all patients
- [ ] Filter by status (active, completed)
- [ ] Search patients
- [ ] Patient details view
- [ ] Consultation history per patient

---

#### 5. Exam Room - Video Call (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 1 week

- [ ] **[PRIORITY: DAY 3]** Video call interface
- [ ] Patient info sidebar
- [ ] Take notes during call
- [ ] Extend time (for SOS calls)
- [ ] End consultation
- [ ] Billing timer
- [ ] Prescription writing

---

#### 6. Doctor Profile Management (Priority: 🟢 Medium)
**Estimated Time:** 3-5 days

- [ ] Edit bio
- [ ] Update specialties
- [ ] Set availability schedule
- [ ] Upload credentials
- [ ] View verification status

---

#### 7. Earnings & Payouts (Priority: 🟡 High)
**Estimated Time:** 1 week

- [ ] Earnings dashboard
- [ ] Standby allowance
- [ ] Consultation fees
- [ ] SOS call bonuses
- [ ] Payout history
- [ ] Tax documents
- [ ] Withdrawal requests

---

#### 8. Patient Notes (Priority: 🟡 High)
**Estimated Time:** 3-5 days

- [ ] Write consultation notes
- [ ] View past notes
- [ ] Share notes with patient (optional)
- [ ] Prescriptions
- [ ] Templates

---

#### 9. Doctor Clubhouse Access (Priority: 🔵 Low)
**Estimated Time:** 3-5 days

- [ ] Doctors can join clubhouse
- [ ] "Medical Room" type
- [ ] Official badge in rooms
- [ ] Host therapy groups

---

#### 10. Analytics (Priority: 🔵 Low)
**Estimated Time:** 3-5 days

- [ ] Patient satisfaction ratings
- [ ] Average consultation time
- [ ] Most common issues
- [ ] Monthly reports

---

## 🛡️ SAFETY & MODERATION (12% Complete)

### ✅ Completed (1/8)

- [x] **Preset Profiles** (Priority: 🔴 Critical)
  - Prevents sexual content 100%

---

### ❌ Missing (7/8)

#### 1. Trust Score System (Priority: 🔴 **CRITICAL**)
**Impact:** Self-moderating community  
**Estimated Time:** 1 week

- [ ] Trust score calculation (0-200)
- [ ] Weighted voting for reports
- [ ] Auto-mute/kick based on trust score
- [ ] Trust score display (admin only)
- [ ] Score adjustment on report validation

**Database:** New `UserTrustScore` model

---

#### 2. Report System (Priority: 🔴 **CRITICAL**)
**Impact:** Community safety  
**Estimated Time:** 3-5 days

- [ ] Report user in room
- [ ] Report reasons (harassment, spam, inappropriate)
- [ ] Report history
- [ ] Admin review panel
- [ ] Report validation (correct/false)

**Database:** New `RoomReport` model

---

#### 3. Community Moderator (Priority: 🟡 High)
**Impact:** Scalable moderation  
**Estimated Time:** 1 week

- [ ] Auto-promotion logic (Trust > 180, Usage > 50h)
- [ ] Mod badge display
- [ ] Mod powers (Mute/Kick)
- [ ] Mod audit log
- [ ] Mod demotion (abuse detection)
- [ ] Mod rewards (badges, exclusive access)

**Database:** New `CommunityModerator`, `ModeratorAction` models

---

#### 4. Block User (Priority: 🟢 Medium)
**Estimated Time:** 2-3 days

- [ ] Block ghost profile
- [ ] Blocked list
- [ ] Prevent blocked users in same room
- [ ] Unblock

---

#### 5. Content Moderation (Priority: 🟢 Medium)
**Estimated Time:** 2-3 days

- [ ] Profanity filter for room titles
- [ ] Banned words list
- [ ] Auto-flag suspicious content

---

#### 6. Admin Panel (Priority: 🟡 High)
**Estimated Time:** 1 week

- [ ] **[PRIORITY: DAY 1]** Advanced Analytics Dashboard (Web)
- [ ] Ban/Unban users
- [ ] View trust scores
- [ ] Mod management
- [ ] Analytics dashboard
- [ ] User search
- **NEW:** (Completed) Next.js Admin Panel Production Deployment 
- **NEW:** (Completed) Secure JS-Cookie Logout & 401 Handling on Dashboard

---

#### 7. User Verification (Priority: 🔵 Low)
**Estimated Time:** 3-5 days

- [ ] Email verification
- [ ] Phone verification (optional)
- [ ] Student verification (for free consultations)

---

#### 8. Crisis Intervention (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 2-3 days

- [ ] Suicide hotline display
- [ ] Crisis resources
- [ ] Auto-escalation for critical PHQ-9 scores
- [ ] Emergency contact notification

---

## 💰 MONETIZATION (0% Complete)

### ❌ All Missing (8/8)

#### 1. Viva Coins Wallet (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 1 week
- [ ] See Telemed #7

#### 2. Top-up System (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 1 week
- [ ] Payment gateway integration
- [ ] Multiple payment methods
- [ ] Receipt generation

#### 3. Pay-per-minute Billing (Priority: 🟡 High)
**Estimated Time:** 3-5 days
- [ ] Real-time billing during consultation
- [ ] Auto-deduct from wallet
- [ ] Billing notifications

#### 4. Subscription Plans (Priority: 🟡 High)
**Estimated Time:** 1 week
- [ ] See Telemed #8

#### 5. Appointment Deposits (Priority: 🟡 High)
**Estimated Time:** 3-5 days
- [ ] 100% deposit on booking
- [ ] Auto-refund (24h cancellation)
- [ ] No-show penalty

#### 6. Refund System (Priority: 🟢 Medium)
**Estimated Time:** 3-5 days
- [ ] Refund requests
- [ ] Admin approval
- [ ] Refund processing

#### 7. Referral Rewards (Priority: 🔵 Low)
**Estimated Time:** 3-5 days
- [ ] See Telemed #9

#### 8. Payment Gateway Integration (Priority: 🔴 **CRITICAL**)
**Estimated Time:** 1 week
- [ ] Stripe/Omise integration
- [ ] Webhook handling
- [ ] Payment security

---

## 🎯 RECOMMENDED IMPLEMENTATION ORDER

### **Phase 1: Complete Clubhouse (2-3 weeks)** 🎙️
**Goal:** Make Clubhouse fully functional and engaging

1. ✅ **Anonymous Subscription** (1-2 weeks) - 🔴 Critical
2. ✅ **Trust Score & Reports** (1 week) - 🔴 Critical
3. ✅ **Enhanced Discovery** (3-5 days) - 🟡 High
4. ✅ **Push Notifications** (3-5 days) - 🟡 High

**Result:** Clubhouse 100% complete, ready for users

---

### **Phase 2: Basic Telemed (3-4 weeks)** 🏥
**Goal:** Enable core telemed functionality

1. ✅ **PHQ-9 Assessment** (1 week) - 🔴 Critical
2. ✅ **Doctor Profiles** (1 week) - 🟡 High
3. ✅ **Appointment Booking** (1 week) - 🟡 High
4. ✅ **Video Call (Basic)** (1 week) - 🟡 High

**Result:** Users can book and consult doctors

---

### **Phase 3: Doctor Side (2-3 weeks)** 👨‍⚕️
**Goal:** Enable doctors to use the platform

1. ✅ **Doctor Auth & Dashboard** (1 week) - 🔴 Critical
2. ✅ **Shift Management** (1 week) - 🔴 Critical
3. ✅ **Exam Room** (1 week) - 🔴 Critical

**Result:** Doctors can manage patients and consultations

---

### **Phase 4: SOS & Monetization (2-3 weeks)** 💰
**Goal:** Critical care and revenue generation

1. ✅ **SOS System** (1 week) - 🔴 Critical
2. ✅ **Wallet & Billing** (1 week) - 🔴 Critical
3. ✅ **Subscription** (1 week) - 🟡 High

**Result:** Full monetization + life-saving features

---

## 📈 Timeline to Full MVP

| Phase | Duration | Cumulative | Completion |
|-------|----------|------------|------------|
| **Current** | - | - | 23% |
| **Phase 1** | 2-3 weeks | 2-3 weeks | ~40% |
| **Phase 2** | 3-4 weeks | 5-7 weeks | ~65% |
| **Phase 3** | 2-3 weeks | 7-10 weeks | ~85% |
| **Phase 4** | 2-3 weeks | 9-13 weeks | ~100% |

**Phase 1-2 Summary:** 
- Clubhouse features are mature.
- Telemed backend foundations (Assessment, Bookings, Notes) are essentially ready.
- The next major blockers are **Flutter UI implementation** for the Telemed flow.

---

## 🚀 Quick Wins & Recent Infrastructure Milestones

**Infrastructure & Bugs Solved (March 1, 2026):**
- ✅ **VPS Deployment:** Docker Compose, Caddy Reverse Proxy, HTTPS Auto-Renew.
- ✅ **Channels WebSocket Fix:** Resolved Redis tuple error that broke real-time chat.
- ✅ **Bot Audio:** Solved stuttering by switching to `time.monotonic()` 10ms pacing.
- ✅ **LiveKit Integration Docs:** Completed architecture mapping (Django ↔ Redis ↔ LiveKit).
- 🟡 **Thai Mobile Network Optimization:** Identified Path MTU Blackhole issue on AIS/True/dtac; implementing TURN over TCP and ICMPv6 Packet Too Big fixes.

**Next High-Impact Tasks:**
1. **Anonymous Subscription** (1-2 weeks) - Core differentiator ⭐
2. **Enhanced Room Discovery** (3-5 days) - Better UX
3. **Trust Score** (1 week) - Critical for safety
4. **PHQ-9 Assessment** (1 week) - Foundation for SOS

**Total: 3-4 weeks = Huge impact!**

---

## 📝 Notes

- **Database models** for many features already exist (GhostSubscription, etc.)
- **LiveKit** already integrated for audio, can extend to video
- **Firebase** already setup for auth and notifications
- **Backend infrastructure** is solid, mostly need API endpoints
- **Frontend** needs most work (new screens, flows)

---

**Last Updated:** 2026-02-15  
**Next Review:** After Phase 1 completion
