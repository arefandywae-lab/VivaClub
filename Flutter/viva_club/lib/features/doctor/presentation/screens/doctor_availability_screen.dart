import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../features/clinical/data/clinical_repository.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  final ClinicalRepository _repository = ClinicalRepository();
  List<dynamic> _slots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    try {
      final slots = await _repository.getMyTimeSlots();
      // Sort by start time
      slots.sort((a, b) => DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
      
      if (mounted) {
        setState(() {
          _slots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addSlot() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final start = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        final end = start.add(const Duration(minutes: 50)); // Default 50 mins

        try {
          setState(() => _isLoading = true);
          await _repository.createTimeSlot(startTime: start, endTime: end);
          _fetchSlots();
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
          }
        }
      }
    }
  }

  Future<void> _deleteSlot(String id) async {
    try {
      await _repository.deleteTimeSlot(id);
      _fetchSlots();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Availability Settings', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addSlot,
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2DD4BF)),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSlots,
              child: _slots.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: _slots.length,
                      itemBuilder: (context, index) => _buildSlotCard(_slots[index]),
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSlot,
        backgroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Time Slot', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text('No availability set', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Set your working hours so patients can book appointments with you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> item) {
    final start = DateTime.parse(item['start_time']);
    final dateStr = DateFormat('EEEE, dd MMM').format(start);
    final timeStr = DateFormat('HH:mm').format(start);
    final isReserved = item['is_reserved'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isReserved ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isReserved ? const Color(0xFFF1F5F9) : const Color(0xFFF0FDFA),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.access_time, color: isReserved ? const Color(0xFF94A3B8) : const Color(0xFF2DD4BF), size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11.sp, fontWeight: FontWeight.bold)),
                Text(timeStr, style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isReserved)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text('BOOKED', style: GoogleFonts.inter(color: const Color(0xFFB45309), fontSize: 10.sp, fontWeight: FontWeight.bold)),
            )
          else
            IconButton(
              onPressed: () => _deleteSlot(item['id'].toString()),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
            ),
        ],
      ),
    );
  }
}
