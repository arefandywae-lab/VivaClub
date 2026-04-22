# Engineering Log: 2026-04-22
## Sprint: VivaClub 3-Day MVP Completion (Day 1 - Patient Side)

### 1. Infrastructure & Security Update
- **Task:** Enhance login security and return user metadata in JWT token.
- **Action:** 
    - Created `CustomTokenObtainPairSerializer` in `apps/users/serializers.py`.
    - Added `user_id`, `role`, `display_name`, and `is_staff` to the authentication response.
- **Rationale:** Reduces extra API calls from mobile client to get user profile after login, improving performance and security.

### 2. Clinical & Communication Backend Expansion
- **Task:** Implement full telemed logic and enhanced communication.
- **Action:**
    - **Models Added (Clinical):**
        - `TimeSlot`, `Appointment`, `SOSCall`, `DoctorReview`.
    - **Models Added (Communication & Notifications):**
        - `DeviceToken` (in `users` app): To store FCM tokens for push notifications across iOS/Android/Web.
        - `ReadReceipt` (in `chat` app): To track message status between doctors and patients.
    - **Logic Implemented:**
        - **SOS Unlock:** Restricted SOS creation to users with PHQ-9 score >= 19.
        - **Cancellation Policy:** Enforced 24-hour limit for appointment cancellation.
        - **Doctor Filtering:** Added specialty and online status filtering.
- **Problem:** Existing `Assessment` model lacked linkage to SOS priority, and chat lacked message status tracking.
- **Solution:** Added `priority_score` to `SOSCall` and implemented `ReadReceipt` model for real-time feedback.

### 3. Next Steps (Planned)
- [ ] Implement WebSocket-based Chat system for Doctor-Patient interaction.
- [ ] Update VPS database schema (Migration).
- [ ] Initialize Flutter UI Blitz using wireframe models.
