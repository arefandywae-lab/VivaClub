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
  runApp(const VivaClubApp());
}

class VivaClubApp extends StatelessWidget {
  const VivaClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => AuthRepository()),
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
              BlocProvider(
                create: (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AuthCheckRequested()),
              ),
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
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
            ),
          ),
        );
      },
    );
  }
}
