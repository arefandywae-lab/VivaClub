# Engineering Log - April 22, 2026

## Summary of Work
Completed the full backend suite for Patient-side Telemedicine features including SOS routing, Appointment booking, and Chat infrastructure. Verified all features via automated API testing on the production VPS.

## Features Implemented
- **Clinical Module:**
  - `TimeSlot` & `Appointment` models for booking flow.
  - `SOSCall` with priority queuing based on PHQ-9 scores.
  - `DoctorReview` for feedback loop.
- **User Module:**
  - `DeviceToken` for FCM push notification support.
  - `CustomTokenObtainPairSerializer` to include user metadata in JWT responses.
- **Chat Module:**
  - `Message` history API and `ReadReceipts`.
- **Infrastructure:**
  - Automated deployment pipeline on VPS via Docker Compose.
  - Caddy reverse proxy configuration for new API routes.

## Problems Encountered & Solutions
1. **Port Conflict on VPS:** 
   - *Problem:* Adminer failed to start due to port 8080 being occupied.
   - *Solution:* Changed mapping to `8082:8080` in `docker-compose.yml`.
2. **Missing Migrations on Deployment:**
   - *Problem:* Backend container reported missing database fields after code update.
   - *Solution:* Generated migrations locally and pushed to Git. Forced remote migration via `docker compose exec`.
3. **Serializer Validation Error:**
   - *Problem:* Appointment booking failed because `doctor` field was required but not sent by client.
   - *Solution:* Set `doctor` as `read_only` in `AppointmentSerializer` and handle assignment in `perform_create` via the selected `TimeSlot`.
4. **NameError in Production:**
   - *Problem:* App crashed due to missing `DeviceToken` import in `serializers.py`.
   - *Solution:* Added explicit import and re-deployed.

## Verification Results
- **Test Script:** `scripts/test_patient_journey.py`
- **Status:** 100% Success (Auth, Assessment, SOS, Booking, Chat, Device Tokens).

---
*End of Day 1 Engineering Log.*
