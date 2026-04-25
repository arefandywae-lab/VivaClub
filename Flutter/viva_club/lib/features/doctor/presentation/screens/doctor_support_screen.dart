import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorSupportScreen extends StatelessWidget {
  const DoctorSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Support Center', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Get help with technical issues or clinical inquiries.',
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14.sp),
            ),
            SizedBox(height: 32.h),
            
            _buildSupportTile(
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat Support',
              subtitle: 'Average response time: 2 mins',
              color: const Color(0xFF2DD4BF),
              onTap: () {},
            ),
            _buildSupportTile(
              icon: Icons.mail_outline,
              title: 'Email Support',
              subtitle: 'support@vivaclubs.site',
              color: const Color(0xFF6366F1),
              onTap: () {},
            ),
            _buildSupportTile(
              icon: Icons.menu_book_outlined,
              title: 'Doctor Guidebook',
              subtitle: 'Learn how to use the clinical portal',
              color: const Color(0xFFF59E0B),
              onTap: () {},
            ),
            
            SizedBox(height: 40.h),
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildFAQ('How do I join a video consultation?', 'Go to your dashboard and tap the video icon on the appointment card.'),
            _buildFAQ('What if a patient doesn\'t show up?', 'Wait for at least 10 minutes, then mark the session as missed if available or contact support.'),
            _buildFAQ('How can I update my medical license?', 'Go to Personal Information in your profile settings.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15.sp)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.sp)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(answer, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13.sp)),
        ],
      ),
    );
  }
}
