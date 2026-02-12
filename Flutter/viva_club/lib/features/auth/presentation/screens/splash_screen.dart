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
            // Simple Logo or Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '🦅', // Hawk Emoji as placeholder logo
                  style: TextStyle(fontSize: 48.sp),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            CircularProgressIndicator(color: AppTheme.skyBlue),
          ],
        ),
      ),
    );
  }
}
