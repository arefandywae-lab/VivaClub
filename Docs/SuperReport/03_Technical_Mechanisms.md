# 03: Key Technical Mechanisms

## 1. Anonymous Ghost Profiles
To protect user identity while maintaining social connection:
- **Generation:** On signup, the system automatically assigns a random animal name (e.g., "Fuzzy Fox") and an emoji avatar.
- **Privacy:** Real names and phone numbers are never exposed in the community zone.
- **Persistence:** Ghost profiles are linked to the user account, allowing users to build a reputation (Trust Score) anonymously.

## 2. PHQ-9 Clinical Assessment & Triage
The foundation of the Telemed system:
- **The Survey:** A standardized 9-question depression screening.
- **Triage Logic:** Scores are calculated instantly. 
    - **0-9:** Low/Moderate (Encouraged to join Clubhouse).
    - **10-18:** Moderate/Severe (Recommended to book a specialist).
    - **19-27:** Critical (Unlocks the SOS Emergency button).

## 3. High-Priority SOS Triage Queue
When a user triggers SOS:
- **Priority Scoring:** Users with the highest clinical risk are moved to the top of the queue.
- **Live Polling:** The Doctor Dashboard polls the `/api/clinical/sos/pending/` endpoint every 10 seconds.
- **Instant Connection:** Upon acceptance, the backend generates a unique LiveKit room. The patient app polls for this "ONGOING" status and auto-joins the call.

## 4. Clubhouse Moderation & Roles
- **Host Migration:** If a host leaves, the system automatically promotes a speaker or moderator to prevent room collapse.
- **Role-based Signaling:** WebSockets send "Hand Raise" signals from listeners to hosts, creating an interactive panel experience.
- **Persistent Moderators:** Moderators are stored in the database, allowing them to retain their powers even if they disconnect and rejoin.
