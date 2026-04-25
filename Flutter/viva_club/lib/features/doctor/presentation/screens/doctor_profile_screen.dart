import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = (state is AuthAuthenticated) ? state.user : {};
        final displayName = user['display_name'] ?? 'Medical Staff';
        final role = user['medical_role'] ?? 'Specialist';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 32.h),
                decoration: BoxDecoration( // Removed const to fix ScreenUtil extension error
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32.r),
                    bottomRight: Radius.circular(32.r),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      displayName,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      role,
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13.sp),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(24.w),
                  children: [
                    _buildMenuTile(
                      Icons.person_outline, 
                      'Personal Information', 
                      'Edit your medical credentials',
                      onTap: () => context.push('/doctor/profile-edit'),
                    ),
                    _buildMenuTile(
                      Icons.history, 
                      'Consultation History', 
                      'View your past sessions',
                      onTap: () => context.push('/doctor/history'),
                    ),
                    _buildMenuTile(
                      Icons.settings_outlined, 
                      'Availability Settings', 
                      'Manage your working hours',
                      onTap: () => context.push('/doctor/availability'),
                    ),
                    _buildMenuTile(
                      Icons.help_outline, 
                      'Support Center', 
                      'Get help with the platform',
                      onTap: () => context.push('/doctor/support'),
                    ),
                    SizedBox(height: 32.h),
                    
                    ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF64748B),
                        elevation: 0,
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text('Switch to Patient Mode', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        foregroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text('Log Out', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF0F172A), size: 20.sp),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.sp)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        onTap: onTap,
      ),
    );
  }
}
