import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // SOS Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF2F2), Color(0xFFFDF2F8)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Color(0xFFEF4444),
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
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "If you're in crisis, reach out for emergency support",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                            child: const Text('Emergency Help (SOS)'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Main Features

              // Telemed Card (HIDDEN AS REQUESTED)
              /*
              _buildFeatureCard(
                context,
                title: 'Talk to a Specialist',
                subtitle: 'Connect with verified mental health professionals',
                icon: Icons.videocam,
                iconColor: Colors.white,
                gradientColors: [AppTheme.skyBlue, AppTheme.mintGreen],
                borderColor: AppTheme.skyBlue.withValues(alpha: 0.3),
                badgeText: 'Book Appointment',
                onTap: () {}, // TODO: Navigate to Telemed
              ),
              SizedBox(height: 16.h),
              */

              // Clubhouse Card
              _buildFeatureCard(
                context,
                title: 'Join Anonymous Group',
                subtitle: 'Share experiences safely in anonymous audio rooms',
                icon: Icons.groups,
                iconColor: const Color(0xFF2D3748),
                gradientColors: [AppTheme.butteryYellow, AppTheme.cottonPink],
                bgOpacity: 0.2, // Lighter background for this one
                iconBgGradient: const [
                  AppTheme.butteryYellow,
                  AppTheme.cottonPink,
                ],
                borderColor: AppTheme.cottonPink.withValues(alpha: 0.3),
                badgeText: 'Explore Rooms',
                badgeColor: AppTheme.cottonPink,
                onTap: () => context.push('/rooms'),
              ),
              SizedBox(height: 16.h),

              // Daily Check-in
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Mood Check-in',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Track your mental wellness journey',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppTheme.butteryYellow.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
}
