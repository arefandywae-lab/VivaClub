import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_event.dart';
import '../bloc/clinical_state.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class SOSWaitingScreen extends StatefulWidget {
  const SOSWaitingScreen({super.key});

  @override
  State<SOSWaitingScreen> createState() => _SOSWaitingScreenState();
}

class _SOSWaitingScreenState extends State<SOSWaitingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Poll queue status every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      context.read<ClinicalBloc>().add(const QueueStatusRequested());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: BlocConsumer<ClinicalBloc, ClinicalState>(
        listener: (context, state) {
          // If a doctor accepts, the backend or a notification would move us to the call screen
          // For now, let's assume we monitor a state change if we had a dedicated "active_sos" field
        },
        builder: (context, state) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPulseCircle(1.0),
                    _buildPulseCircle(0.7),
                    _buildPulseCircle(0.4),
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent,
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(Icons.emergency_rounded, size: 60.w, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 60.h),
                Text(
                  'Emergency Support',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                SizedBox(height: 12.h),
                Text(
                  'We are finding the best specialist for you.\nPlease stay on this screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600], height: 1.5),
                ),
                SizedBox(height: 48.h),
                
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(strokeWidth: 3, color: Colors.redAccent),
                      SizedBox(width: 20.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Queue Position',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                          ),
                          Text(
                            'Number ${state.queuePosition}',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 80.h),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel Request',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseCircle(double scale) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: (120.w + (100.w * _controller.value)) * scale,
          height: (120.w + (100.w * _controller.value)) * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withOpacity((1 - _controller.value) * 0.3 * scale),
          ),
        );
      },
    );
  }
}
