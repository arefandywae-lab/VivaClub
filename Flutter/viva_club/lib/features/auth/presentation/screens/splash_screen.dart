import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viva_club/core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset('assets/images/logo.png', width: 120.w, height: 120.w),
            SizedBox(height: 24.h),
            CircularProgressIndicator(color: AppTheme.skyBlue),
          ],
        ),
      ),
    );
  }
}
