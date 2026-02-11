# Viva Club - Flutter Mobile App

## Architecture
We follow a **Feature-First** architecture combined with **Clean Architecture** principles.

### Folder Structure (`lib/`)
```
lib/
├── core/                   # Shared logic (Network, Themes, Constants)
│   ├── network/            # Dio setup, Interceptors
│   ├── theme/              # AppTheme, Colors, Type
│   ├── router/             # GoRouter configuration
│   └── constants/          # API Endpoints, Keys
├── features/
│   ├── auth/               # Feature: Authentication
│   │   ├── data/           # Repositories, Data Sources
│   │   ├── domain/         # Entities, UseCases
│   │   └── presentation/   # BLoCs, Screens, Widgets
│   ├── community/          # Feature: Clubhouse/Voice Rooms
│   └── telemed/            # Feature: Doctor/Patient Video
├── main.dart
└── app.dart
```

## Tech Stack
*   **State Management**: `flutter_bloc`
*   **Navigation**: `go_router`
*   **Networking**: `dio`
*   **Real-time Media**: `livekit_client`
*   **UI/Responsiveness**: `flutter_screenutil`, `google_fonts`
*   **Local Storage**: `shared_preferences` / `flutter_secure_storage`

## Design System (Pastel Theme)
*   **Primary**: `#A8D8EA` (Sky Blue)
*   **Secondary**: `#B4E4D6` (Mint Green)
*   **Accent**: `#FFF5BA` (Buttery Yellow)
*   **Background**: `#FAFBFC`
*   **Text**: `#4A5568`

## Features
1.  **Auth**: Login (Phone/Password), Register (Generate GhostID).
2.  **Clubhouse**:
    *   List Rooms.
    *   Create Room.
    *   Join Room (Live Audio via LiveKit).
3.  **Telemed** (Coming Soon).
