# 05: Sustainability & Security

## 1. Green App Initiative (Energy Efficiency)
VivaClub was built with sustainability as a core principle, focusing on reducing the carbon footprint of mobile usage:
- **Deep Dark Mode:** Implemented a true OLED-friendly black theme (#000000) to significantly reduce power consumption on modern mobile displays.
- **Optimized Media Pacing:** Reducing CPU wake-ups by batching network packets and optimizing audio playback loops.
- **Resource Minimization:** Utilizing vector icons and Emoji-based identities to reduce asset download sizes, saving both data and server energy.

## 2. Robust Authentication & Data Security
- **JWT (JSON Web Tokens):** Used for secure, stateless authentication between the mobile app and the backend.
- **Password Recovery:** Integrated with a real SMTP server to provide secure, email-based password resets, eliminating the risk of account lockout.
- **Data Privacy:** Clinical notes (OPD Notes) are encrypted at rest and only accessible by authorized medical professionals and the patient.

## 3. Production Hardening
- **Reverse Proxy (Caddy):** Provides automatic SSL/TLS encryption, ensuring all data transmitted between the client and server is encrypted.
- **Environment Isolation:** Using `.env` files and Docker secrets to ensure sensitive credentials (API keys, DB passwords) are never hardcoded or exposed in the version control system.
- **Access Control:** Role-based access control (RBAC) ensures that only users with the `DOCTOR` role can access the SOS queue and patient clinical records.
