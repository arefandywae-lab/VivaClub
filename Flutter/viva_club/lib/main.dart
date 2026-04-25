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
import 'features/clinical/data/clinical_repository.dart';
import 'features/clinical/presentation/bloc/clinical_bloc.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize notifications and request permission
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Auth dependencies at root to share with Router
  final authRepository = AuthRepository();
  final authBloc = AuthBloc(authRepository: authRepository)
    ..add(AuthCheckRequested());
  
  final clinicalRepository = ClinicalRepository();
  final clinicalBloc = ClinicalBloc(clinicalRepository: clinicalRepository);

  final chatRepository = ChatRepository();
  final chatBloc = ChatBloc(chatRepository: chatRepository);

  runApp(VivaClubApp(
    authRepository: authRepository, 
    authBloc: authBloc,
    clinicalRepository: clinicalRepository,
    clinicalBloc: clinicalBloc,
    chatRepository: chatRepository,
    chatBloc: chatBloc,
  ));
}

class VivaClubApp extends StatelessWidget {
  final AuthRepository authRepository;
  final AuthBloc authBloc;
  final ClinicalRepository clinicalRepository;
  final ClinicalBloc clinicalBloc;
  final ChatRepository chatRepository;
  final ChatBloc chatBloc;

  const VivaClubApp({
    super.key,
    required this.authRepository,
    required this.authBloc,
    required this.clinicalRepository,
    required this.clinicalBloc,
    required this.chatRepository,
    required this.chatBloc,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize Router with the AuthBloc
    final appRouter = AppRouter(authBloc);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: clinicalRepository),
        RepositoryProvider.value(value: chatRepository),
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
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: clinicalBloc),
          BlocProvider.value(value: chatBloc),
          BlocProvider(
            create: (context) => RoomBloc(
              communityRepository: context.read<CommunityRepository>(),
            )..add(const RoomLoad()),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(
              profileRepository: context.read<ProfileRepository>(),
            )..add(ProfileLoad()),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Viva Club',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              routerConfig: appRouter.router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
