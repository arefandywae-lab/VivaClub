import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/theme/app_theme.dart';
import '../../../../core/utils/emoji_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/data/profile_repository.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileRepo = ProfileRepository();
  final _bioController = TextEditingController();

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
    _bioController.dispose();
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

    final bio = ghostProfile?['bio'] as String? ?? '';

    return Column(
      children: [
        _buildHeader(displayName, memberSince, state.trustScore),
        SizedBox(height: 16.h),
        // Bio section
        _buildBioSection(bio),
        SizedBox(height: 12.h),
        // Action row: Following + Blocked Users
        _buildActionRow(),
        SizedBox(height: 8.h),
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

  // ──────────────────────────────────────────────
  // BIO SECTION
  // ──────────────────────────────────────────────
  Widget _buildBioSection(String bio) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GestureDetector(
        onTap: () => _showBioEditDialog(bio),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✍️ About Me',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      bio.isEmpty ? 'Tap to add your bio...' : bio,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: bio.isEmpty
                            ? Colors.grey.shade400
                            : AppTheme.textDark,
                        fontStyle: bio.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.edit_rounded,
                size: 18.sp,
                color: AppTheme.primary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBioEditDialog(String currentBio) {
    _bioController.text = currentBio;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '✍️ Edit Your Bio',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Tell others a bit about yourself (anonymous).',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textGrey),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _bioController,
                maxLength: 200,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'I enjoy sharing my feelings in safe spaces...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13.sp,
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textGrey,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await _profileRepo.updateBio(
                            _bioController.text.trim(),
                          );
                          if (mounted) {
                            context.read<ProfileBloc>().add(ProfileLoad());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Bio updated!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ACTION ROW (Following + Blocked)
  // ──────────────────────────────────────────────
  Widget _buildActionRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          _buildActionCard(
            icon: '👥',
            label: 'Following',
            onTap: () => context.push('/following'),
          ),
          SizedBox(width: 12.w),
          _buildActionCard(
            icon: '🚫',
            label: 'Blocked',
            onTap: () => context.push('/blocked_users'),
          ),
          SizedBox(width: 12.w),
          _buildActionCard(
            icon: '🔒',
            label: 'Privacy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: TextStyle(fontSize: 22.sp)),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
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

    // Determine the color and text based on the score
    Color scoreColor = Colors.green;
    String statusWord = 'Good';
    if (score < 50) {
      scoreColor = Colors.redAccent;
      statusWord = 'Poor';
    } else if (score < 90) {
      scoreColor = Colors.orange;
      statusWord = 'Fair';
    } else if (score >= 150) {
      scoreColor = AppTheme.skyBlue;
      statusWord = 'Excellent';
    }

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
              // Small Logout Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      context.read<AuthBloc>().add(AuthLogoutRequested()),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Quick Stats
          Row(
            children: [
              _buildStatCard(
                'TRUST',
                '🛡️',
                score.toString(),
                subtitle: statusWord,
                valueColor: scoreColor,
              ),
              SizedBox(width: 12.w),
              _buildStatCard('MOOD', '🙂', 'Good'),
              SizedBox(width: 12.w),
              _buildStatCard('STREAK', '🔥', '5 Days'),
            ],
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
        padding: EdgeInsets.all(12.w),
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
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(icon, style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: valueColor ?? AppTheme.textDark,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 10.sp,
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
    final doctor = apt['doctor_details'] ?? {};
    final doctorName = doctor['display_name'] ?? doctor['username'] ?? 'Doctor';
    final specialty = doctor['specialty'] ?? '';
    final startTime = apt['start_time'] ?? '';
    final status = apt['status'] ?? '';
    final isConfirmed = status == 'confirmed';

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
              if (isConfirmed)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Confirmed',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.orange.shade700,
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
                _formatDateTime(startTime),
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textDark),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.videocam, size: 14.sp, color: AppTheme.textGrey),
              SizedBox(width: 8.w),
              Text(
                'Video Call',
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
                  // TODO: Navigate to video call with room ID
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.skyBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('Join Session'),
              ),
            ),
          ],
        ],
      ),
    );
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
