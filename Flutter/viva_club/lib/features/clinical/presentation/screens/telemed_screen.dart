import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_state.dart';

class TelemedScreen extends StatelessWidget {
  const TelemedScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              
              // Assessment Card
              _buildFeatureCard(
                title: 'Mental Health Assessment',
                subtitle: 'Take the PHQ-9 test to understand your mental state better.',
                icon: Icons.assignment_outlined,
                color: const Color(0xFF6C63FF),
                onTap: () => context.push('/clinical/assessment'),
              ),
              
              SizedBox(height: 24.h),
              
              // SOS Card
              BlocBuilder<ClinicalBloc, ClinicalState>(
                builder: (context, state) {
                  final isUnlocked = state.riskLevel != null;
                  return _buildFeatureCard(
                    title: 'Emergency SOS',
                    subtitle: isUnlocked 
                      ? 'Immediate assistance for urgent mental health distress.'
                      : 'Complete your assessment to unlock this feature.',
                    icon: Icons.emergency_rounded,
                    color: Colors.redAccent,
                    onTap: isUnlocked 
                      ? () => context.push('/clinical/sos-waiting')
                      : null,
                    isLocked: !isUnlocked,
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
              color: color.withOpacity(0.08),
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
                      color: Colors.grey[500],
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
