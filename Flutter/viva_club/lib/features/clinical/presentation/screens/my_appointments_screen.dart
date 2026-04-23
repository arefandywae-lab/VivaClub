import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/clinical_repository.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    try {
      final repository = context.read<ClinicalRepository>();
      final apps = await repository.getMyAppointments();
      setState(() {
        _appointments = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _appointments.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchAppointments,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _appointments.length,
                itemBuilder: (context, index) => _buildAppointmentCard(_appointments[index]),
              ),
            ),
    );
  }

  Widget _buildAppointmentCard(dynamic app) {
    final startTime = DateTime.parse(app['slot_details']['start_time']);
    final doctor = app['doctor_details'];
    final status = app['status'];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.person, color: Color(0xFF6C63FF)),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor['display_name'], style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    Text(doctor['specialty'] ?? 'Specialist', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8.w),
              Text(DateFormat('EEEE, MMM d').format(startTime), style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8.w),
              Text(DateFormat('HH:mm').format(startTime), style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
            ],
          ),
          if (status == 'Scheduled' || status == 'Ongoing') ...[
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                       context.push('/chat', extra: {
                         'room_id': app['id'].toString(),
                         'token': 'temporary_token', // In real app, fetch from join endpoint
                         'title': doctor['display_name'],
                       });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Chat'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       context.push('/clinical/video-call', extra: {
                         'url': 'wss://vivaclub-c8l1bt1p.livekit.cloud',
                         'token': 'temporary_token', // In real app, fetch from join endpoint
                         'room_name': 'appointment_${app['id']}',
                       });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Join Call', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.blue;
    if (status == 'Completed') color = Colors.grey;
    if (status == 'Ongoing') color = Colors.green;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80.w, color: Colors.grey[200]),
          SizedBox(height: 16.h),
          Text('No appointments yet', style: TextStyle(fontSize: 18.sp, color: Colors.grey[400])),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.go('/telemed'),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }
}
