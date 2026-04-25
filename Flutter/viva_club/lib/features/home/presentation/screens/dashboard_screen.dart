import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_club/core/theme/app_theme.dart';
import 'package:viva_club/features/community/presentation/bloc/room_bloc.dart';
import 'package:viva_club/features/clinical/presentation/bloc/clinical_bloc.dart';
import 'package:viva_club/features/clinical/presentation/bloc/clinical_state.dart';
import 'package:viva_club/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:viva_club/core/utils/emoji_utils.dart';
import 'package:viva_club/features/clinical/data/clinical_repository.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh profile whenever dashboard is shown to ensure latest mood/streak
    context.read<AuthBloc>().add(ProfileRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomBloc, RoomState>(
      listener: (context, state) {
        if (state is RoomJoined) {
          // If we are currently on the create_room screen, pop it first to avoid it staying in stack
          // This prevents the "back button goes to create room" issue.
          final router = GoRouter.of(context);
          final location = router.routerDelegate.currentConfiguration.last.matchedLocation;
          
          if (location == '/create_room') {
            context.pop();
          }

          context.push('/live_room', extra: {
            'url': state.url,
            'token': state.token,
            'room_id': state.roomId,
            'title': state.title,
            'is_host': state.isHost,
          });
        } else if (state is RoomFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Welcome to Viva Club',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your safe space for mental health & community',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGrey),
                ),
                SizedBox(height: 24.h),

                // Daily Stats Card
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      final mood = state.user['current_mood'] ?? 'UNKNOWN';
                      final streak = state.user['streak_count'] ?? 0;
                      
                      String moodLabel = mood;
                      IconData moodIconData = Icons.mood;
                      Color moodColor = const Color(0xFF6C63FF); // Default Purple
                      
                      if (mood == 'SEVERE') {
                        moodIconData = Icons.sentiment_very_dissatisfied;
                        moodColor = Colors.red;
                        moodLabel = 'Severe';
                      } else if (mood == 'MODERATE') {
                        moodIconData = Icons.sentiment_neutral;
                        moodColor = Colors.orange;
                        moodLabel = 'Moderate';
                      } else if (mood == 'LOW') {
                        moodIconData = Icons.sentiment_very_satisfied;
                        moodColor = Colors.green;
                        moodLabel = 'Low';
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: 24.h),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildStatItem(
                              icon: Icons.local_fire_department,
                              color: Colors.orange,
                              label: 'Daily Streak',
                              value: '$streak Days',
                            ),
                            Container(width: 1, height: 40.h, color: Colors.grey[100]),
                            _buildStatItem(
                              icon: moodIconData,
                              color: moodColor,
                              label: 'Current Mood',
                              value: moodLabel,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                // Upcoming Appointment Section
                _buildUpcomingAppointment(),
                
                SizedBox(height: 24.h),

                // SOS Card (SYNCED WITH TELEMED)
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return BlocBuilder<ClinicalBloc, ClinicalState>(
                      builder: (context, clinicalState) {
                        // Check if EITHER the current session assessment is SEVERE
                        // OR the user's profile current_mood is SEVERE
                        bool isUnlocked = clinicalState.riskLevel != null;
                        if (authState is AuthAuthenticated) {
                          if (authState.user['current_mood'] == 'SEVERE') {
                            isUnlocked = true;
                          }
                        }

                        return Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isUnlocked
                                  ? [const Color(0xFFFEF2F2), const Color(0xFFFDF2F8)]
                                  : [Colors.grey[100]!, Colors.grey[50]!],
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: isUnlocked ? const Color(0xFFFEE2E2) : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: isUnlocked ? const Color(0xFFFEE2E2) : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isUnlocked ? Icons.error_outline : Icons.lock_outline,
                                  color: isUnlocked ? const Color(0xFFEF4444) : Colors.grey[400],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Need Immediate Help?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: isUnlocked ? AppTheme.textDark : Colors.grey[400],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      isUnlocked
                                          ? "If you're in crisis, reach out for emergency support"
                                          : "Complete your assessment to unlock emergency SOS",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    ElevatedButton(
                                      onPressed: isUnlocked
                                          ? () => context.push('/clinical/sos-waiting')
                                          : () => context.go('/telemed'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isUnlocked ? const Color(0xFFEF4444) : Colors.grey[400],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16.r),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                      ),
                                      child: Text(isUnlocked ? 'Emergency Help (SOS)' : 'Unlock SOS'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 32.h),

                // ACTIVE ROOMS SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Rooms',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/rooms'), // Use .go for Nav Sync
                      child: const Text(
                        'See All',
                        style: TextStyle(color: AppTheme.skyBlue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                BlocBuilder<RoomBloc, RoomState>(
                  builder: (context, state) {
                    if (state is RoomInitial) {
                      context.read<RoomBloc>().add(const RoomLoad());
                      return const SizedBox();
                    }
                    if (state is RoomLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is RoomLoaded) {
                      final activeRooms = state.rooms.where((r) => r['is_active'] == true).take(3).toList();
                      if (activeRooms.isEmpty) {
                        return _buildEmptyRooms(context);
                      }
                      return Column(
                        children: activeRooms.map((room) => _buildMiniRoomCard(context, room)).toList(),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                SizedBox(height: 24.h),

                // Clubhouse Card
                _buildFeatureCard(
                  context,
                  title: 'Join Anonymous Group',
                  subtitle: 'Share experiences safely in anonymous audio rooms',
                  icon: Icons.groups,
                  iconColor: const Color(0xFF2D3748),
                  gradientColors: [AppTheme.butteryYellow, AppTheme.cottonPink],
                  bgOpacity: 0.2,
                  iconBgGradient: const [
                    AppTheme.butteryYellow,
                    AppTheme.cottonPink,
                  ],
                  borderColor: AppTheme.cottonPink.withValues(alpha: 0.3),
                  badgeText: 'Explore Rooms',
                  badgeColor: AppTheme.cottonPink,
                  onTap: () => context.go('/rooms'), // Use .go for Nav Sync
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRooms(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text('👻', style: TextStyle(fontSize: 40.sp)),
          SizedBox(height: 12.h),
          Text(
            'No active rooms right now',
            style: TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () => context.push('/create_room'),
            child: const Text('Start one?'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRoomCard(BuildContext context, Map<String, dynamic> room) {
    final String title = room['title'] ?? 'Untitled Room';
    final String hostName = room['host_details']?['display_name'] ?? 'Unknown Host';
    final int listeners = room['listeners_count'] ?? 0;

    return GestureDetector(
      onTap: () => context.read<RoomBloc>().add(RoomJoin(room['id'])),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppTheme.skyBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  EmojiUtils.getEmojiForName(hostName),
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'with $hostName',
                    style: TextStyle(fontSize: 11.sp, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.mintGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.headphones, size: 12.sp, color: AppTheme.mintGreen),
                  SizedBox(width: 4.w),
                  Text(
                    listeners.toString(),
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppTheme.mintGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required List<Color> iconBgGradient,
    required Color borderColor,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
    double bgOpacity = 0.1,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors
                .map((c) => c.withValues(alpha: bgOpacity))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: iconBgGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 28.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: AppTheme.textGrey,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14.sp, color: AppTheme.textGrey),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointment() {
    return FutureBuilder<List<dynamic>>(
      future: context.read<ClinicalRepository>().getMyAppointments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();

        final now = DateTime.now();
        // Filter confirmed or pending appointments that are either in the future or ongoing (within 1 hour)
        final upcoming = snapshot.data!.where((app) {
          final status = app['status'];
          if (status != 'CONFIRMED' && status != 'PENDING') return false;
          
          final slotDetail = app['slot_detail'];
          if (slotDetail == null || slotDetail['start_time'] == null) return false;
          
          final startTime = DateTime.parse(slotDetail['start_time'].toString());
          final endTime = startTime.add(const Duration(hours: 1));
          
          return endTime.isAfter(now);
        }).toList();

        if (upcoming.isEmpty) return const SizedBox();

        // Sort by start time to get the closest one
        upcoming.sort((a, b) {
          final t1 = DateTime.parse(a['slot_detail']['start_time'].toString());
          final t2 = DateTime.parse(b['slot_detail']['start_time'].toString());
          return t1.compareTo(t2);
        });

        final closest = upcoming.first;
        final startTime = DateTime.parse(closest['slot_detail']['start_time'].toString());
        final doctor = closest['doctor_detail'] ?? {};
        final status = closest['status'];
        final isOngoing = now.isAfter(startTime) && now.isBefore(startTime.add(const Duration(hours: 1)));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Appointment',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isOngoing ? const Color(0xFF6C63FF) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: (isOngoing ? const Color(0xFF6C63FF) : Colors.black).withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isOngoing ? const Color(0xFF6C63FF) : Colors.grey[100]!,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: (isOngoing ? Colors.white : const Color(0xFF6C63FF)).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: isOngoing ? Colors.white : const Color(0xFF6C63FF),
                          size: 20.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOngoing ? 'Happening Now' : 'Scheduled Session',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isOngoing ? Colors.white70 : Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              doctor['display_name'] ?? 'Doctor',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isOngoing ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status, inverse: isOngoing),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.w,
                        color: isOngoing ? Colors.white70 : Colors.grey[400],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${DateFormat('MMM d').format(startTime)} at ${DateFormat('HH:mm').format(startTime)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isOngoing ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      if (status == 'CONFIRMED') 
                        TextButton(
                          onPressed: () async {
                             if (isOngoing) {
                               try {
                                 // Show loading dialog
                                 showDialog(
                                   context: context,
                                   barrierDismissible: false,
                                   builder: (context) => const Center(child: CircularProgressIndicator()),
                                 );
                                 
                                 final joinInfo = await context.read<ClinicalRepository>().joinAppointment(closest['id'].toString());
                                 
                                 if (context.mounted) {
                                   context.pop(); // Close loading
                                   context.push('/clinical/video-call', extra: {
                                     'url': joinInfo['url'],
                                     'token': joinInfo['token'],
                                     'room_name': joinInfo['room_name'],
                                   });
                                 }
                               } catch (e) {
                                 if (context.mounted) {
                                   context.pop(); // Close loading
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                   );
                                 }
                               }
                             } else {
                               context.push('/chat', extra: {
                                 'room_id': closest['id'].toString(),
                                 'token': 'temporary_token',
                                 'title': doctor['display_name'] ?? 'Doctor',
                               });
                             }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: isOngoing ? Colors.white : const Color(0xFF6C63FF),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isOngoing ? 'Join Now' : 'Chat',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, {bool inverse = false}) {
    Color color = Colors.blue;
    if (status == 'PENDING') color = Colors.orange;
    if (status == 'CONFIRMED') color = Colors.green;
    
    if (inverse) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.w),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
