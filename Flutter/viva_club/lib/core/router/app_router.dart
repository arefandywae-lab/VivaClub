import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/community/presentation/screens/room_list_screen.dart';
import '../../features/community/presentation/screens/create_room_screen.dart';
import '../../features/community/presentation/screens/live_room_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/clinical/presentation/screens/telemed_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

// Keys for navigation state preservation
final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Screens WITHOUT Bottom Nav
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/live_room',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return LiveRoomScreen(
            url: extra['url'] ?? '',
            token: extra['token'] ?? '',
            roomId: extra['room_id'] ?? '',
            title: extra['title'] ?? 'Live Room',
            isHost: extra['is_host'] ?? false,
          );
        },
      ),
      GoRoute(
        path: '/create_room',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateRoomScreen(),
      ),

      // Screens WITH Bottom Nav (ShellRoute)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home/Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 2: Telemed
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/telemed',
                builder: (context, state) => const TelemedScreen(),
              ),
            ],
          ),

          // Branch 3: Clubhouse
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rooms',
                builder: (context, state) => const RoomListScreen(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
