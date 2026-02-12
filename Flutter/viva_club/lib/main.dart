import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/community/data/community_repository.dart';
import 'features/community/presentation/bloc/room_bloc.dart';

import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/community/data/livekit_room_service.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Auth dependencies at root to share with Router
  final authRepository = AuthRepository();
  final authBloc = AuthBloc(authRepository: authRepository)
    ..add(AuthCheckRequested());

  runApp(VivaClubApp(authRepository: authRepository, authBloc: authBloc));
}

class VivaClubApp extends StatelessWidget {
  final AuthRepository authRepository;
  final AuthBloc authBloc;

  const VivaClubApp({
    super.key,
    required this.authRepository,
    required this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize Router with the AuthBloc
    final appRouter = AppRouter(authBloc);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: authRepository),
            RepositoryProvider(create: (context) => CommunityRepository()),
            RepositoryProvider(create: (context) => ProfileRepository()),
          ],
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => LiveKitRoomService(
                  communityRepository: context.read<CommunityRepository>(),
                ),
              ),
              // Use BlocProvider.value to provide the existing instance
              BlocProvider.value(value: authBloc),
              BlocProvider(
                create: (context) => RoomBloc(
                  communityRepository: context.read<CommunityRepository>(),
                )..add(RoomLoad()),
              ),
              BlocProvider(
                create: (context) => ProfileBloc(
                  profileRepository: context.read<ProfileRepository>(),
                )..add(ProfileLoad()),
              ),
            ],
            child: MaterialApp.router(
              title: 'Viva Club',
              theme: AppTheme.lightTheme,
              routerConfig: appRouter.router,
              debugShowCheckedModeBanner: false,
            ),
          ),
        );
      },
    );
  }
}
