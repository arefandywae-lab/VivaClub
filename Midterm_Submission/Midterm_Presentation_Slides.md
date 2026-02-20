# Slide 1: Title Slide
**Title:** VivaClub: Midterm Progress Presentation
**Subtitle:** A Real-time Audio Community Platform
**Team Members:** 
- [Your Name 1] - ID: [Your Student ID 1]
- [Your Name 2] - ID: [Your Student ID 2]

---

# Slide 2: Project Overview
**What is VivaClub?**
- An audio-first community platform (inspired by Clubhouse).
- Allows users to create and join live voice-chat rooms.
- Extends the traditional social audio concept by integrating **Telemedicine/Professional Booking** features for private, scheduled audio consultations.

---

# Slide 3: Technology Stack
- **Frontend:** Flutter (Cross-platform Mobile UI)
- **Backend:** Django REST Framework (Python)
- **Database:** PostgreSQL
- **Real-Time Audio:** LiveKit (WebRTC Engine)
- **Deployment:** Docker & Railway

---

# Slide 4: Midterm Progress - Backend
**What we've built so far:**
- **Secure Auth:** JWT Authentication & Custom User Profiles.
- **Room APIs:** Endpoints to Create, List, Join, and Leave rooms.
- **WebRTC Token Generation:** Secure handshake giving clients access to LiveKit Audio Channels.
- **Moderation APIs:** Integration with LiveKit Server API to *Force Mute* or *Kick* participants dynamically via the backend.

---

# Slide 5: Midterm Progress - Frontend (Mobile App)
**What we've built so far:**
- **Live Room UI:** Grids displaying "Speakers" and "Listeners".
- **Dynamic Interactions:**
  - **Hand Raise:** Listeners can push a button to signal they want to speak.
  - **Host Options:** Hosts receive a UI dialog to *Invite*, *Mute*, or *Kick* users instantly.
- **Cross-Platform Readiness:** Tested on iOS physical devices using Developer Provisioning Profiles.

---

# Slide 6: Demonstration (Screenshots / Video)
*(Placeholder: Insert screenshots of the App here!)*
- Show the Dashboard / Room List.
- Show the Live Room Screen (showing a Host and Listener).
- Show the "Manage Speaker" dialog (Mute/Kick).

---

# Slide 7: Next Steps & Final Goals
**What's remaining for the Final Submission?**
- **Telemedicine Booking System:** UI and API for scheduling doctors/professionals.
- **Monetization & Wallet:** In-app virtual currency for tipping and booking fees.
- **Push Notifications:** Firebase (FCM) alerts when a room starts or an appointment is upcoming.

---

# Slide 8: Q&A
**Thank You!**
Are there any questions about our implementation or architecture?
