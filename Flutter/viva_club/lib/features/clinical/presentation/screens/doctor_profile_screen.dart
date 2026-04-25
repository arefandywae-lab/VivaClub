import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/clinical_repository.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  List<dynamic> _allSlots = [];
  bool _isLoadingSlots = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() => _isLoadingSlots = true);
    try {
      final repository = context.read<ClinicalRepository>();
      final slots = await repository.getTimeSlots(widget.doctor['id']);
      setState(() {
        _allSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() => _isLoadingSlots = false);
    }
  }

  List<dynamic> _getSlotsForDay(DateTime day) {
    return _allSlots.where((slot) {
      final slotDate = DateTime.parse(slot['start_time']);
      return isSameDay(slotDate, day);
    }).toList();
  }

  bool _hasSlotsOnDay(DateTime day) {
    return _getSlotsForDay(day).isNotEmpty;
  }

  Future<void> _handleBooking() async {
    if (_selectedSlotId == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = context.read<ClinicalRepository>();
      await repository.bookAppointment(_selectedSlotId!);
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Request Sent!'),
        content: const Text('Your booking request has been sent. Please wait for the doctor to confirm.'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go('/clinical/my-appointments'); // Go to appointments to see pending status
            },
            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailySlots = _selectedDay != null ? _getSlotsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About'),
                  SizedBox(height: 8.h),
                  Text(
                    'Certified ${widget.doctor['specialty'] ?? 'Specialist'} with years of experience in supporting mental well-being.',
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[600], height: 1.5),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Select Date'),
                  SizedBox(height: 12.h),
                  _buildCalendar(),
                  SizedBox(height: 24.h),
                  if (_selectedDay != null) ...[
                    _buildSectionTitle('Available Time'),
                    SizedBox(height: 16.h),
                    _isLoadingSlots
                        ? const Center(child: CircularProgressIndicator())
                        : dailySlots.isEmpty
                            ? Text('No slots available for this day.', style: TextStyle(color: Colors.grey[400]))
                            : _buildSlotsGrid(dailySlots),
                  ],
                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedSlotId = null; // Reset selection
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.3), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (_hasSlotsOnDay(day)) {
              return Center(
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('${day.day}')),
                ),
              );
            }
            return null;
          },
        ),
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      ),
    );
  }

  Widget _buildSlotsGrid(List<dynamic> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final startTime = DateTime.parse(slot['start_time']);
        final isSelected = _selectedSlotId == slot['id'];
        
        return GestureDetector(
          onTap: () => setState(() => _selectedSlotId = slot['id']),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                DateFormat('HH:mm').format(startTime),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Text(
                widget.doctor['display_name'],
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.doctor['specialty'] ?? 'Specialist',
                style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6C63FF)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _selectedSlotId != null ? _handleBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              _selectedSlotId != null ? 'Request Appointment' : 'Select a Slot',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
