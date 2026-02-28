import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/router/go_router_refresh_stream.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart'; // Import Splash
import '../../features/community/presentation/screens/room_list_screen.dart';
import '../../features/community/presentation/screens/create_room_screen.dart';
import '../../features/community/presentation/screens/live_room_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/clinical/presentation/screens/telemed_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/community/presentation/screens/following_list_screen.dart';
import '../../features/community/presentation/bloc/following_bloc.dart';
import '../../features/community/data/following_repository.dart';
import '../../core/network/dio_client.dart';
import '../../features/profile/presentation/screens/blocked_users_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

// Keys for navigation state preservation
final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash', // Start at Splash
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isSplash = state.uri.toString() == '/splash';

      // 1. If initializing, stay on splash
      if (authState is AuthInitial) {
        return isSplash ? null : '/splash';
      }

      final isLoggedIn = authState is AuthAuthenticated;
      final isLoggingIn =
          state.uri.toString() == '/login' ||
          state.uri.toString() == '/signup' ||
          state.uri.toString() == '/';

      // 2. If splash is done (we have a definitive state)
      if (isSplash) {
        return isLoggedIn ? '/dashboard' : '/';
      }

      // 3. Normal auth guards
      // If not logged in and not on a public page, go to welcome
      if (!isLoggedIn && !isLoggingIn) return '/';

      // If logged in and on a public page, go to dashboard
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      return null;
    },
    routes: [
      // Screens WITHOUT Bottom Nav
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/blocked_users',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: '/following',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) => FollowingBloc(FollowingRepository(DioClient())),
          child: const FollowingListScreen(),
        ),
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
