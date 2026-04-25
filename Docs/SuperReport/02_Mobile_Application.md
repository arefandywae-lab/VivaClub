# 02: Mobile Application - Flutter & UX/UI

## 1. Development Framework
**Flutter** was chosen for its high-performance rendering and the ability to maintain a single codebase for both iOS and Android. This ensured feature parity across all user devices.

## 2. State Management (BLoC Pattern)
We implemented the **BLoC (Business Logic Component)** pattern to separate presentation from business logic.
- **Benefits:** Predictable state transitions, ease of testing, and modular code.
- **Key Blocs:** `AuthBloc`, `RoomBloc` (Clubhouse), and `ClinicalBloc` (Telemed).

## 3. Design Philosophy (Aesthetics & UX)
- **Rich Visuals:** Usage of modern typography (Google Fonts - Inter/Poppins) and vibrant gradients to create a premium feel.
- **Accessibility:** High-contrast elements and clear iconography for ease of use by users in distress.
- **Glassmorphism:** Subtle usage of blurred backgrounds to create depth in the UI.

## 4. Portals and Roles
The application features a dual-portal system:
1. **Patient Portal:** Focused on community (Clubhouse) and seeking help (Telemed).
2. **Doctor Portal:** Focused on consultation management, patient tracking, and real-time SOS response.

## 5. Optimization Techniques
- **ScreenUtil:** Ensuring responsive layouts across different screen sizes.
- **Lazy Loading:** Efficiently loading room lists and patient history to save bandwidth and memory.
- **Asset Optimization:** Using Lottie and optimized PNGs to keep the app bundle small and performant.
