import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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

  List<dynamic> _getSlotsForDay(DateTime day) {
    return _slots.where((slot) {
      final slotDate = DateTime.parse(slot['start_time']);
      return isSameDay(slotDate, day);
    }).toList();
  }

  Future<void> _addSlot() async {
    final DateTime? pickedDate = _selectedDay;
    if (pickedDate == null) return;

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
    final dailySlots = _selectedDay != null ? _getSlotsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Availability Calendar', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 30)),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: _getSlotsForDay,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.3), shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                      markerDecoration: const BoxDecoration(color: Color(0xFF2DD4BF), shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Text(
                        _selectedDay == null ? 'Select a day' : DateFormat('EEEE, dd MMM').format(_selectedDay!),
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                      const Spacer(),
                      Text('${dailySlots.length} Slots', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12.sp)),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: dailySlots.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: dailySlots.length,
                          itemBuilder: (context, index) => _buildSlotCard(dailySlots[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSlot,
        backgroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Slot', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text('No slots for this day', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> item) {
    final start = DateTime.parse(item['start_time']);
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
            child: Text(timeStr, style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
