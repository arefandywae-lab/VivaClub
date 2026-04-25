import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../features/clinical/data/clinical_repository.dart';

class DoctorPatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorPatientDetailScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorPatientDetailScreen> createState() => _DoctorPatientDetailScreenState();
}

class _DoctorPatientDetailScreenState extends State<DoctorPatientDetailScreen> {
  final ClinicalRepository _repository = ClinicalRepository();
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientHistory();
  }

  Future<void> _fetchPatientHistory() async {
    try {
      final apps = await _repository.getMyAppointments();
      // Filter appointments for this specific patient
      final patientHistory = apps.where((app) => app['patient'].toString() == widget.patientId).toList();
      // Sort by date descending
      patientHistory.sort((a, b) {
        final dateA = DateTime.parse(a['scheduled_at'] ?? a['created_at']);
        final dateB = DateTime.parse(b['scheduled_at'] ?? b['created_at']);
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _history = patientHistory;
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
        title: Text('Patient Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    color: Colors.white,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40.r,
                          backgroundColor: const Color(0xFFF1F5F9),
                          child: Text(
                            widget.patientName[0].toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(widget.patientName, style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text('Patient ID: #${widget.patientId}', style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF94A3B8))),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Total Visits', _history.length.toString()),
                            _buildDivider(),
                            _buildStatItem('Last Visit', _history.isNotEmpty ? _formatDate(_history.first['scheduled_at'] ?? _history.first['created_at']) : 'N/A'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(24.w),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Consultation History',
                      style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                  ),
                ),
                _history.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyHistory())
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildHistoryCard(_history[index]),
                            childCount: _history.length,
                          ),
                        ),
                      ),
                SliverToBoxAdapter(child: SizedBox(height: 40.h)),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        Text(label, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30.h, width: 1.w, color: const Color(0xFFE2E8F0));
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: Text('No history available', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final date = DateTime.parse(item['scheduled_at'] ?? item['created_at']);
    final dateStr = DateFormat('dd MMM yyyy').format(date);
    final timeStr = DateFormat('HH:mm').format(date);
    final notes = item['clinical_notes'] ?? 'No clinical notes recorded for this session.';
    final status = (item['status'] ?? 'unknown').toString().toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text(timeStr, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF94A3B8))),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: status == 'COMPLETED' ? const Color(0xFFF0FDFA) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: status == 'COMPLETED' ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text('CLINICAL NOTES', style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
          SizedBox(height: 8.h),
          Text(
            notes,
            style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF475569), height: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}
