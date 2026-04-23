import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_event.dart';
import '../bloc/clinical_state.dart';
import 'package:go_router/go_router.dart';

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ClinicalBloc, ClinicalState>(
        builder: (context, state) {
          final riskColor = _getRiskColor(state.riskLevel);
          
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(40.w),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRiskIcon(state.riskLevel),
                    size: 80.w,
                    color: riskColor,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Your Score: ${state.totalScore}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Risk Level: ${state.riskLevel ?? "Unknown"}',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: riskColor,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  _getRiskMessage(state.riskLevel),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 48.h),
                
                // SOS Button (Always shown if high risk, or maybe we show a warning)
                if (state.totalScore >= 19)
                  _buildActionButton(
                    label: 'EMERGENCY SOS',
                    color: Colors.redAccent,
                    onPressed: () {
                      context.read<ClinicalBloc>().add(const SOSRequested());
                      context.push('/clinical/sos-waiting');
                    },
                  ),
                
                SizedBox(height: 16.h),
                
                _buildActionButton(
                  label: 'Browse Specialists',
                  color: const Color(0xFF6C63FF),
                  onPressed: () => context.push('/clinical/doctors'),
                  isOutline: state.totalScore >= 19,
                ),
                
                SizedBox(height: 16.h),
                
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.white : color,
          foregroundColor: isOutline ? color : Colors.white,
          elevation: 0,
          side: isOutline ? BorderSide(color: color, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getRiskColor(String? risk) {
    switch (risk) {
      case 'SEVERE': return Colors.red;
      case 'MODERATE': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.blue;
    }
  }

  IconData _getRiskIcon(String? risk) {
    switch (risk) {
      case 'SEVERE': return Icons.warning_rounded;
      case 'MODERATE': return Icons.info_outline_rounded;
      case 'LOW': return Icons.check_circle_outline_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  String _getRiskMessage(String? risk) {
    switch (risk) {
      case 'SEVERE':
        return 'Your score suggests high distress. Please consider reaching out to our emergency support immediately.';
      case 'MODERATE':
        return 'You might be experiencing some challenges. Talking to a professional could help you feel better.';
      case 'LOW':
        return 'Your mental health seems to be in a good place. Keep maintaining your well-being!';
      default:
        return 'Thank you for completing the assessment.';
    }
  }
}
