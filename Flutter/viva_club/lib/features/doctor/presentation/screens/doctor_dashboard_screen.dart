import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../features/clinical/data/clinical_repository.dart';
import 'package:intl/intl.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final ClinicalRepository _repository = ClinicalRepository();
  final TextEditingController _searchController = TextEditingController();
  bool isOnline = false;
  List<dynamic> _appointments = [];
  List<dynamic> _filteredAppointments = [];
  bool _isLoading = true;
  Timer? _sosTimer;
  int _waitingSosCount = 0;
  Map<String, dynamic>? _activeSos;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
    _startSosPolling();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sosTimer?.cancel();
    super.dispose();
  }

  void _startSosPolling() {
    _sosTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isOnline) {
        _checkSos();
      }
    });
  }

  Future<void> _checkSos() async {
    try {
      final response = await _repository.getQueuePosition(); // Reusing this or adding list_waiting
      // Actually, let's use a new method or the dashboard one
      final dashboardData = await _dio.get('/api/clinical/doctors/dashboard/');
      if (mounted) {
        setState(() {
          _waitingSosCount = dashboardData.data['waiting_sos_count'] ?? 0;
        });
        if (_waitingSosCount > 0) {
          _fetchWaitingSos();
        }
      }
    } catch (e) {
      // Silent error for polling
    }
  }

  final _dio = DioClient().dio;

  Future<void> _fetchWaitingSos() async {
    try {
      final response = await _dio.get('/api/clinical/sos/list_waiting/');
      final List<dynamic> waiting = response.data;
      if (waiting.isNotEmpty && mounted) {
        setState(() {
          _activeSos = waiting.first;
        });
      }
    } catch (e) {}
  }

  Future<void> _acceptSos() async {
    if (_activeSos == null) return;
    try {
      final response = await _dio.post('/api/clinical/sos/${_activeSos!['id']}/accept/');
      if (mounted) {
        context.push('/doctor/exam-room', extra: {
          'url': response.data['livekit_url'] ?? 'wss://vivaclubs.site', // Fallback or from env
          'token': response.data['livekit_token'],
          'room_name': response.data['room_name'],
          'patient_name': _activeSos!['patient_display_name'] ?? 'Urgent Patient',
          'appointment_id': _activeSos!['id'], 
          'is_sos': true,
        });
        setState(() => _activeSos = null);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAppointments = _appointments.where((app) {
        final name = (app['patient_display_name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchData() async {
    try {
      final apps = await _repository.getMyAppointments();
      if (mounted) {
        setState(() {
          _appointments = apps;
          _filteredAppointments = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(bool value) async {
    try {
      await _repository.updateDoctorStatus(value);
      setState(() => isOnline = value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _joinCall(Map<String, dynamic> appointment) async {
    try {
      final data = await _repository.joinAppointment(appointment['id'].toString());
      if (mounted) {
        context.push('/doctor/exam-room', extra: {
          'url': data['url'],
          'token': data['token'],
          'room_name': data['room_name'],
          'patient_name': appointment['patient_display_name'] ?? 'Anonymous Panda',
          'appointment_id': appointment['id'],
          'is_sos': false,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32.r),
                    bottomRight: Radius.circular(32.r),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clinical Dashboard',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Manage your daily appointments',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        _buildHeaderIcon(
                          Icons.notifications_none_outlined, 
                          _waitingSosCount > 0 || _appointments.any((a) => a['status'] == 'pending'),
                          onTap: () => context.push('/doctor/notifications'),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    
                    // SOS Alert Banner (Existing)
                    if (_activeSos != null)
                      _buildSosBanner(),

                    // Quick Stats Row
                    Row(
                      children: [
                        _buildStatCard('Completed', '24', Icons.check_circle_outline, const Color(0xFF10B981)),
                        SizedBox(width: 12.w),
                        _buildStatCard('Pending', '03', Icons.pending_actions, const Color(0xFFF59E0B)),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton('History', Icons.history, () => context.push('/doctor/history')),
                        _buildActionButton('Availability', Icons.event_available, () => context.push('/doctor/availability')),
                        _buildActionButton('Profile', Icons.person_search, () => context.push('/doctor/profile-edit')),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Status Toggle Card
                    _buildStatusToggle(),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader("Today's Consultations", "${_filteredAppointments.length} Total"),
                  SizedBox(height: 16.h),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_filteredAppointments.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredAppointments.map((item) => _buildScheduleCard(item)),
                  SizedBox(height: 100.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 18.sp, fontWeight: FontWeight.bold)),
        Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 48.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text(_searchController.text.isEmpty ? 'No appointments today' : 'No matching patients', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
          Text(_searchController.text.isEmpty ? 'Your schedule is clear for now.' : 'Try a different name or session ID.', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildSosBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMERGENCY SOS',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
                Text(
                  _activeSos!['patient_display_name'] ?? 'Urgent Patient',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Priority Score: ${_activeSos!['priority_score']}',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _acceptSos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: Text('ACCEPT', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 12.h),
            Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w, height: 10.w,
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFF22C55E) : const Color(0xFF64748B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isOnline ? 'Active Status' : 'Inactive Status', 
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      Text(isOnline ? 'Accepting Patients' : 'Offline Mode', 
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10.sp)),
                    ],
                  ),
                ],
              ),
              Switch(
                value: isOnline,
                onChanged: _toggleStatus,
                activeColor: const Color(0xFF2DD4BF),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search my patients...',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? 'unknown').toString().toUpperCase();
    final isWaiting = status == 'PENDING' || status == 'CONFIRMED';
    
    // Fallback for time display
    String? rawTime = item['scheduled_at'];
    if (rawTime == null && item['slot_detail'] != null) {
      rawTime = item['slot_detail']['start_time'];
    }
    
    final timeStr = rawTime != null 
        ? DateFormat('HH:mm').format(DateTime.parse(rawTime))
        : '--:--';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 8.w),
                  Text(timeStr, style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isWaiting ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: isWaiting ? const Color(0xFF059669) : const Color(0xFF64748B),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['patient_display_name'] ?? 'Anonymous Patient',
                      style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Session ID: #${item['id']}',
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              if (isWaiting)
                GestureDetector(
                  onTap: () => _joinCall(item),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF0D9488).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: const Icon(Icons.videocam, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, bool hasNotification, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
        child: Stack(
          children: [
            Icon(icon, color: const Color(0xFFCBD5E1), size: 20.sp),
            if (hasNotification)
              Positioned(
                right: 0, top: 0,
                child: Container(
                  width: 8.w, height: 8.w,
                  decoration: BoxDecoration(color: const Color(0xFFEF4444), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0F172A), width: 2)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
