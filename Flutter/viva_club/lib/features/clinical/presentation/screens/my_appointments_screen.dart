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
    try {
      final slotDetail = app['slot_detail'];
      if (slotDetail == null || slotDetail['start_time'] == null) {
        return _buildErrorCard('Missing time slot information');
      }

      final startTime = DateTime.parse(slotDetail['start_time'].toString());
      final doctor = app['doctor_detail'] ?? {};
      final status = (app['status'] ?? 'UNKNOWN').toString();
      final appId = (app['id'] ?? 'none').toString();

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
                      Text(doctor['display_name']?.toString() ?? 'Doctor', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      Text(doctor['specialty']?.toString() ?? 'Specialist', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
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
            if (status == 'CONFIRMED') ...[
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                         context.push('/chat', extra: {
                           'room_id': appId,
                           'token': 'temporary_token',
                           'title': doctor['display_name']?.toString() ?? 'Doctor',
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
                      onPressed: () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );
                          
                          final joinInfo = await context.read<ClinicalRepository>().joinAppointment(app['id'].toString());
                          
                          if (context.mounted) {
                            context.pop();
                            context.push('/clinical/video-call', extra: {
                              'url': joinInfo['url'],
                              'token': joinInfo['token'],
                              'room_name': joinInfo['room_name'],
                            });
                          }
                        } catch (e) {
                          if (context.mounted) {
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
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
    } catch (e) {
      return _buildErrorCard('Error rendering card: $e');
    }
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16)),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final statusStr = status ?? 'UNKNOWN';
    Color color = Colors.blue;
    if (statusStr == 'PENDING') color = Colors.orange;
    if (statusStr == 'CONFIRMED') color = Colors.green;
    if (statusStr == 'COMPLETED') color = Colors.grey;
    if (statusStr == 'CANCELLED') color = Colors.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(statusStr, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.bold)),
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
