import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../features/clinical/data/clinical_repository.dart';

class DoctorConsultationHistoryScreen extends StatefulWidget {
  const DoctorConsultationHistoryScreen({super.key});

  @override
  State<DoctorConsultationHistoryScreen> createState() => _DoctorConsultationHistoryScreenState();
}

class _DoctorConsultationHistoryScreenState extends State<DoctorConsultationHistoryScreen> {
  final ClinicalRepository _repository = ClinicalRepository();
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final apps = await _repository.getMyAppointments();
      // Filter for completed or past appointments
      final pastApps = apps.where((app) => 
        app['status'] == 'COMPLETED' || 
        app['status'] == 'completed' ||
        DateTime.parse(app['scheduled_at']).isBefore(DateTime.now())
      ).toList();
      
      // Sort by date descending
      pastApps.sort((a, b) => DateTime.parse(b['scheduled_at']).compareTo(DateTime.parse(a['scheduled_at'])));

      if (mounted) {
        setState(() {
          _history = pastApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Consultation History', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: _history.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: _history.length,
                      itemBuilder: (context, index) => _buildHistoryCard(_history[index]),
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text('No history found', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
          Text('Your completed sessions will appear here.', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final date = DateTime.parse(item['scheduled_at']);
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);
    final notes = item['clinical_notes'] ?? 'No notes recorded for this session.';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11.sp, fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text('COMPLETED', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 9.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            item['patient_display_name'] ?? 'Anonymous Patient',
            style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLINICAL NOTES', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                SizedBox(height: 4.h),
                Text(
                  notes,
                  style: GoogleFonts.inter(color: const Color(0xFF334155), fontSize: 13.sp, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
