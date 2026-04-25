import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class DoctorPersonalInfoScreen extends StatefulWidget {
  const DoctorPersonalInfoScreen({super.key});

  @override
  State<DoctorPersonalInfoScreen> createState() => _DoctorPersonalInfoScreenState();
}

class _DoctorPersonalInfoScreenState extends State<DoctorPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dio = DioClient().dio;
  
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _licenseController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final user = (state is AuthAuthenticated) ? state.user : {};
    
    _nameController = TextEditingController(text: user['display_name'] ?? '');
    _specialtyController = TextEditingController(text: user['specialty'] ?? '');
    _licenseController = TextEditingController(text: user['license_id'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _dio.patch('/api/auth/profile/', data: {
        'display_name': _nameController.text.trim(),
        'specialty': _specialtyController.text.trim(),
        'license_id': _licenseController.text.trim(),
      });
      
      if (mounted) {
        // Refresh Auth State to reflect changes
        context.read<AuthBloc>().add(AuthCheckRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Color(0xFF2DD4BF)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Personal Information', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Public Profile'),
              SizedBox(height: 16.h),
              _buildInputField(
                label: 'Display Name',
                controller: _nameController,
                hint: 'e.g. Dr. Somsak Viva',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 20.h),
              _buildInputField(
                label: 'Medical Specialty',
                controller: _specialtyController,
                hint: 'e.g. Psychiatrist',
                icon: Icons.medical_services_outlined,
              ),
              SizedBox(height: 32.h),
              _buildSectionTitle('Medical Credentials'),
              SizedBox(height: 16.h),
              _buildInputField(
                label: 'Medical License ID',
                controller: _licenseController,
                hint: 'e.g. MD123456',
                icon: Icons.verified_user_outlined,
              ),
              SizedBox(height: 48.h),
              
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ),
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
      style: GoogleFonts.inter(
        color: const Color(0xFF64748B),
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: const Color(0xFF334155), fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20.sp),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFF0F172A)),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }
}
