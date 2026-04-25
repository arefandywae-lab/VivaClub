import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_state.dart';
import 'package:viva_club/features/auth/presentation/bloc/auth_bloc.dart';

import 'dart:async';

class TelemedScreen extends StatefulWidget {
  const TelemedScreen({super.key});

  @override
  State<TelemedScreen> createState() => _TelemedScreenState();
}

class _TelemedScreenState extends State<TelemedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getCooldownRemaining(String? lastDateStr) {
    if (lastDateStr == null) return '';
    try {
      final lastDate = DateTime.parse(lastDateStr).toUtc();
      final nextAvailable = lastDate.add(const Duration(hours: 24));
      final now = DateTime.now().toUtc();

      if (now.isAfter(nextAvailable)) return '';

      final diff = nextAvailable.difference(now);
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String cooldown = '';
    bool isAssessmentLocked = false;
    
    if (authState is AuthAuthenticated) {
      cooldown = _getCooldownRemaining(authState.user['last_assessment_date']);
      isAssessmentLocked = cooldown.isNotEmpty;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              Text(
                'Telemedicine',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              Text(
                'Professional mental health support anytime.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32.h),
              
              // Assessment Card with Cooldown
              _buildFeatureCard(
                title: 'Mental Health Assessment',
                subtitle: isAssessmentLocked 
                  ? 'Available in $cooldown'
                  : 'Take the PHQ-9 test to understand your mental state better.',
                icon: Icons.assignment_outlined,
                color: const Color(0xFF6C63FF),
                onTap: isAssessmentLocked ? null : () => context.push('/clinical/assessment'),
                isLocked: isAssessmentLocked,
                subtitleColor: isAssessmentLocked ? Colors.redAccent : null,
              ),
              
              SizedBox(height: 24.h),
              
              // SOS Card
              BlocBuilder<ClinicalBloc, ClinicalState>(
                builder: (context, clinicalState) {
                  bool isSOSUnlocked = clinicalState.riskLevel != null;
                  if (authState is AuthAuthenticated) {
                    if (authState.user['current_mood'] == 'SEVERE') {
                      isSOSUnlocked = true;
                    }
                  }
                  
                  return _buildFeatureCard(
                    title: 'Emergency SOS',
                    subtitle: isSOSUnlocked 
                      ? 'Immediate assistance for urgent mental health distress.'
                      : 'Complete your assessment to unlock this feature.',
                    icon: Icons.emergency_rounded,
                    color: Colors.redAccent,
                    onTap: isSOSUnlocked 
                      ? () => context.push('/clinical/sos-waiting')
                      : null,
                    isLocked: !isSOSUnlocked,
                  );
                },
              ),
              
              SizedBox(height: 24.h),
              
              // Appointment Card
              _buildFeatureCard(
                title: 'Book a Specialist',
                subtitle: 'Find and schedule a session with our certified psychiatrists.',
                icon: Icons.calendar_month_outlined,
                color: const Color(0xFF48A7FF),
                onTap: () => context.push('/clinical/doctors'),
              ),

              SizedBox(height: 24.h),

              // My Appointments Card
              _buildFeatureCard(
                title: 'My Appointments',
                subtitle: 'View your upcoming sessions and join your consultations.',
                icon: Icons.event_note_outlined,
                color: const Color(0xFFFFA048),
                onTap: () => context.push('/clinical/my-appointments'),
              ),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool isLocked = false,
    Color? subtitleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isLocked ? Colors.transparent : color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey[100] : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isLocked ? Icons.lock_outline_rounded : icon,
                color: isLocked ? Colors.grey[400] : color,
                size: 28.w,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey[400] : const Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: subtitleColor ?? Colors.grey[500],
                      fontWeight: subtitleColor != null ? FontWeight.bold : FontWeight.normal,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLocked)
              Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
