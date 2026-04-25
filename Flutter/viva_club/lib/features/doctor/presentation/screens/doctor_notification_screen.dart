import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';

class DoctorNotificationScreen extends StatefulWidget {
  const DoctorNotificationScreen({super.key});

  @override
  State<DoctorNotificationScreen> createState() => _DoctorNotificationScreenState();
}

class _DoctorNotificationScreenState extends State<DoctorNotificationScreen> {
  final _dio = DioClient().dio;
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await _dio.get('/api/community/notifications/');
      if (mounted) {
        setState(() {
          _notifications = response.data['notifications'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _dio.post('/api/community/notifications/read-all/');
      _fetchNotifications();
    } catch (e) {}
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _dio.post('/api/community/notifications/$id/read/');
      _fetchNotifications();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          if (_notifications.any((n) => n['is_read'] == false))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text('Mark all read', style: GoogleFonts.inter(color: const Color(0xFF0D9488), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty 
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) => _buildNotificationCard(_notifications[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text('No notifications', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
          Text('When you get updates, they\'ll appear here.', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    bool isRead = n['is_read'] ?? false;
    final date = DateTime.parse(n['created_at']);
    final dateStr = DateFormat('dd MMM, HH:mm').format(date);

    return GestureDetector(
      onTap: () => _markAsRead(n['id']),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF0FDFA),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFF2DD4BF).withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFF2DD4BF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(n['type']), 
                color: isRead ? const Color(0xFF94A3B8) : const Color(0xFF0D9488), 
                size: 20.sp
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(n['title'] ?? 'Notification', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      if (!isRead)
                        Container(width: 8.w, height: 8.w, decoration: const BoxDecoration(color: Color(0xFF2DD4BF), shape: BoxShape.circle)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(n['body'] ?? '', style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF475569), height: 1.4)),
                  SizedBox(height: 8.h),
                  Text(dateStr, style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'SOS': return Icons.warning_amber_rounded;
      case 'APPOINTMENT': return Icons.calendar_today_outlined;
      case 'CHAT': return Icons.chat_bubble_outline;
      default: return Icons.notifications_outlined;
    }
  }
}
