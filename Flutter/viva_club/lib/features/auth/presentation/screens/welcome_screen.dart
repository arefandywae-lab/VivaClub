import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.skyBlue.withValues(alpha: 0.1),
              AppTheme.mintGreen.withValues(alpha: 0.1),
              AppTheme.butteryYellow.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Hero Icon
                Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    gradient: const LinearGradient(
                      colors: [AppTheme.skyBlue, AppTheme.mintGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.skyBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.favorite, color: Colors.white, size: 48.w),
                ),
                SizedBox(height: 32.h),

                // Title
                Text(
                  'Viva Club',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Your Safe Space for Mind & Community',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppTheme.textGrey),
                ),
                SizedBox(height: 48.h),

                // Features Card
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.security,
                        iconColor: AppTheme.skyBlue,
                        title: 'Professional Care',
                        subtitle:
                            'Connect with verified mental health specialists',
                      ),
                      SizedBox(height: 24.h),
                      _buildFeatureItem(
                        icon: Icons.favorite_border,
                        iconColor: AppTheme.cottonPink, // Pink
                        title: 'Anonymous Support',
                        subtitle: 'Share freely in our safe audio community',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Get Started Button
                Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: const LinearGradient(
                      colors: [AppTheme.skyBlue, AppTheme.mintGreen],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.mintGreen.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'We respect your privacy. Minimal data collected.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20.w),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14.sp, color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
