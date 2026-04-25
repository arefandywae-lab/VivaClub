import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _showOnlineStatus = true;
  bool _allowDiscovery = true;
  bool _readReceipts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textDark, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '🔒 Privacy Settings',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          _buildInfoBox(),
          SizedBox(height: 32.h),
          _SectionHeader(label: 'Visibility'),
          _buildToggleTile(
            'Online Status',
            'Show when you are active in the app',
            _showOnlineStatus,
            (val) => setState(() => _showOnlineStatus = val),
          ),
          _buildToggleTile(
            'Discoverable',
            'Allow others to find your ghost profile',
            _allowDiscovery,
            (val) => setState(() => _allowDiscovery = val),
          ),
          SizedBox(height: 24.h),
          _SectionHeader(label: 'Messaging'),
          _buildToggleTile(
            'Read Receipts',
            'Show when you\'ve seen a message',
            _readReceipts,
            (val) => setState(() => _readReceipts = val),
          ),
          SizedBox(height: 32.h),
          _buildDangerZone(),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.skyBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Text('🛡️', style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Your privacy is our priority. Ghost profiles are designed to keep you anonymous by default.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.skyBlue.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.mintGreen,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textGrey,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: 'Data Management'),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Permanently remove all your data. This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textGrey,
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Start Deletion Process',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
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
