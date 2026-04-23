import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/clinical_repository.dart';
import 'package:intl/intl.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  List<dynamic> _slots = [];
  bool _isLoadingSlots = true;
  int? _selectedSlotIndex;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() => _isLoadingSlots = true);
    try {
      final repository = context.read<ClinicalRepository>();
      final slots = await repository.getTimeSlots(widget.doctor['id']);
      setState(() {
        _slots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _handleBooking() async {
    if (_selectedSlotIndex == null) return;
    
    final slot = _slots[_selectedSlotIndex!];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = context.read<ClinicalRepository>();
      await repository.bookAppointment(slot['id']);
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
        title: const Text('Booking Successful!'),
        content: const Text('Your appointment has been confirmed. You will receive a reminder 15 minutes before the session.'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go('/telemed'); // Go back to home
            },
            child: const Text('Great!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Certified ${widget.doctor['specialty'] ?? 'Specialist'} with years of experience in supporting mental well-being. Dedicated to providing a safe space for everyone.',
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[600], height: 1.5),
                  ),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Available Slots'),
                  SizedBox(height: 16.h),
                  _isLoadingSlots
                      ? const Center(child: CircularProgressIndicator())
                      : _slots.isEmpty
                          ? const Text('No available slots for now.')
                          : _buildSlotsList(),
                  SizedBox(height: 120.h), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF6C63FF), width: 3),
                  ),
                  child: Icon(Icons.person, size: 60.w, color: Colors.grey[400]),
                ),
                SizedBox(height: 16.h),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSlotsList() {
    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _slots.length,
        itemBuilder: (context, index) {
          final slot = _slots[index];
          final startTime = DateTime.parse(slot['start_time']);
          final isSelected = _selectedSlotIndex == index;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedSlotIndex = index),
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM d').format(startTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(startTime),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
            onPressed: _selectedSlotIndex != null ? _handleBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              _selectedSlotIndex != null ? 'Confirm Booking' : 'Select a Slot',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
