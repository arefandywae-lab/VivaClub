import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textDark,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '⚙️ Settings',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // ACCOUNT SECTION
          _SectionHeader(label: 'Account'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.people_alt_rounded,
            iconColor: AppTheme.skyBlue,
            label: 'Following',
            subtitle: 'Ghosts you follow',
            onTap: () => context.push('/following'),
          ),
          _SettingsTile(
            icon: Icons.block_rounded,
            iconColor: Colors.redAccent,
            label: 'Blocked Users',
            subtitle: 'Manage blocked ghosts',
            onTap: () => context.push('/blocked_users'),
          ),

          SizedBox(height: 20.h),

          // PRIVACY SECTION
          _SectionHeader(label: 'Privacy & Safety'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.lock_rounded,
            iconColor: Colors.orange,
            label: 'Privacy Settings',
            subtitle: 'Control who can see you',
            onTap: () => context.push('/privacy_settings'),
          ),
          _SettingsTile(
            icon: Icons.shield_rounded,
            iconColor: Colors.green,
            label: 'Trust & Safety',
            subtitle: 'View your trust score and reports',
            onTap: () => context.push('/trust_safety'),
          ),

          SizedBox(height: 20.h),

          // NOTIFICATIONS SECTION
          _SectionHeader(label: 'Notifications'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            iconColor: AppTheme.primary,
            label: 'Push Notifications',
            subtitle: 'Configure alerts and reminders',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Push notifications coming soon')),
              );
            },
          ),

          SizedBox(height: 20.h),

          // ABOUT SECTION
          _SectionHeader(label: 'About'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.grey,
            label: 'App Version',
            subtitle: 'VivaClub v1.0.0',
            onTap: null,
          ),
          _SettingsTile(
            icon: Icons.description_rounded,
            iconColor: Colors.grey,
            label: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: () {},
          ),

          SizedBox(height: 28.h),

          // LOGOUT
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    title: const Text('Logout'),
                    content: const Text(
                      'Are you sure you want to leave VivaClub?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11.sp, color: AppTheme.textGrey),
        ),
        trailing: onTap != null
            ? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400)
            : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
    );
  }
}
