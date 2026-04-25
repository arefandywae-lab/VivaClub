import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/utils/emoji_utils.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Trigger a fresh load every time this screen is shown
    context.read<ProfileBloc>().add(ProfileLoad());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileFailure) {
            // Auto logout if session expired for better UX (especially for demos)
            if (state.message.contains('Session expired')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              });
            }
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProfileBloc>().add(ProfileLoad()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProfileLoaded) {
            return _buildLoadedContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, ProfileLoaded state) {
    final user = state.user;
    final ghostProfile = user['ghost_profile'];
    final displayName =
        ghostProfile?['display_name'] ??
        user['display_name'] ??
        user['username'] ??
        'User';
    final memberSince = user['date_joined'] != null
        ? 'Member since ${_formatDate(user['date_joined'])}'
        : 'Welcome to VivaClub';

    return Column(
      children: [
        _buildHeader(displayName, memberSince, state.trustScore),
        SizedBox(height: 16.h),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingTab(state.upcomingAppointments),
              _buildHistoryTab(state.pastAppointments),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildHeader(
    String displayName,
    String memberSince,
    Map<String, dynamic> trustScoreInfo,
  ) {
    final int score = trustScoreInfo['score'] ?? 100;

    // Score color/status processing removed since Trust card now matches Mood/Streak style

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.skyBlue.withValues(alpha: 0.15),
            AppTheme.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Gradient ring emoji avatar
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.skyBlue, AppTheme.mintGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        EmojiUtils.getEmojiForName(displayName),
                        style: TextStyle(fontSize: 36.sp),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            EmojiUtils.getNameWithoutTag(displayName),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (EmojiUtils.getTagFromName(
                          displayName,
                        ).isNotEmpty) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.skyBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              EmojiUtils.getTagFromName(displayName),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.skyBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      memberSince,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings Button
              GestureDetector(
                onTap: () => context.push('/settings'),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: AppTheme.textGrey,
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Quick Stats
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                final mood = state.user['current_mood'] ?? 'UNKNOWN';
                final streak = state.user['streak_count'] ?? 0;
                
                String moodIcon = '🙂';
                String moodDisplay = mood;
                Color moodColor = AppTheme.textDark;
                
                if (mood == 'SEVERE') {
                  moodIcon = '😞';
                  moodDisplay = 'Severe';
                  moodColor = Colors.red;
                } else if (mood == 'MODERATE') {
                  moodIcon = '😐';
                  moodDisplay = 'Moderate';
                  moodColor = Colors.orange;
                } else if (mood == 'LOW') {
                  moodIcon = '😊';
                  moodDisplay = 'Low';
                  moodColor = Colors.green;
                }

                return Row(
                  children: [
                    _buildStatCard('TRUST', '🛡️', score.toString()),
                    SizedBox(width: 12.w),
                    _buildStatCard('MOOD', moodIcon, moodDisplay, valueColor: moodColor),
                    SizedBox(width: 12.w),
                    _buildStatCard('STREAK', '🔥', '$streak'),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String icon,
    String value, {
    String? subtitle,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(icon, style: TextStyle(fontSize: 12.sp)),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: valueColor ?? AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: valueColor ?? AppTheme.textGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        labelColor: AppTheme.textDark,
        unselectedLabelColor: AppTheme.textGrey,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  // ────────────── UPCOMING TAB ──────────────
  Widget _buildUpcomingTab(List<dynamic> appointments) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ProfileBloc>().add(ProfileLoad()),
      child: appointments.isEmpty
          ? ListView(
              children: [
                SizedBox(height: 80.h),
                Center(
                  child: Column(
                    children: [
                      Text('🗓️', style: TextStyle(fontSize: 48.sp)),
                      SizedBox(height: 12.h),
                      Text(
                        'No upcoming appointments',
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Book a session with a doctor\nfrom the Telemed tab',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final apt = appointments[index];
                return _buildAppointmentCard(apt);
              },
            ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt) {
    try {
      final doctor = apt['doctor_detail'] ?? {};
      final doctorName = doctor['display_name'] ?? doctor['username'] ?? 'Doctor';
      final specialty = doctor['specialty'] ?? '';
      
      final slotDetail = apt['slot_detail'] ?? {};
      final startTimeStr = slotDetail['start_time'] ?? '';
      final status = apt['status'] ?? 'UNKNOWN';
      final isConfirmed = status == 'CONFIRMED';
      final isPending = status == 'PENDING';

      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    EmojiUtils.getEmojiForName(doctorName),
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      if (specialty.isNotEmpty)
                        Text(
                          specialty,
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isConfirmed ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: isConfirmed ? Colors.green.shade700 : Colors.orange.shade700,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: AppTheme.textGrey),
                SizedBox(width: 8.w),
                Text(
                  _formatDateTime(startTimeStr),
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textDark),
                ),
              ],
            ),
            if (isConfirmed) ...[
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/clinical/video-call', extra: {
                      'url': 'wss://vivaclub-c8l1bt1p.livekit.cloud',
                      'token': 'temporary_token',
                      'room_name': 'appointment_${apt['id']}',
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.skyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    elevation: 0,
                  ),
                  child: const Text('Join Session'),
                ),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16)),
        child: Text('Error rendering: $e', style: const TextStyle(color: Colors.red)),
      );
    }
  }

  String _formatDateTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final now = DateTime.now();
      final dayLabel =
          (dt.year == now.year && dt.month == now.month && dt.day == now.day)
          ? 'Today'
          : '${months[dt.month - 1]} ${dt.day}';
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$dayLabel, $hour:$minute $ampm';
    } catch (_) {
      return isoDate;
    }
  }

  // ────────────── HISTORY TAB ──────────────
  Widget _buildHistoryTab(List<dynamic> pastAppointments) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ProfileBloc>().add(ProfileLoad()),
      child: pastAppointments.isEmpty
          ? ListView(
              children: [
                SizedBox(height: 80.h),
                Center(
                  child: Column(
                    children: [
                      Text('📋', style: TextStyle(fontSize: 48.sp)),
                      SizedBox(height: 12.h),
                      Text(
                        'No past consultations yet',
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView(
              padding: EdgeInsets.all(24.w),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Past Consultations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Download All',
                        style: TextStyle(
                          color: AppTheme.skyBlue,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                ...pastAppointments.map((record) => _buildHistoryCard(record)),
                SizedBox(height: 40.h),
              ],
            ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final doctor = record['doctor_details'] ?? {};
    final doctorName = doctor['display_name'] ?? doctor['username'] ?? 'Doctor';
    final date = _formatDateTime(record['start_time'] ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12.sp),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  Text(
                    '5.0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 12.sp,
              color: AppTheme.textDark,
            ),
            label: Text(
              'View Summary',
              style: TextStyle(color: AppTheme.textDark, fontSize: 12.sp),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
