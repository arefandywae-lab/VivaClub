import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/clinical/data/clinical_repository.dart';

class DoctorPatientListScreen extends StatefulWidget {
  const DoctorPatientListScreen({super.key});

  @override
  State<DoctorPatientListScreen> createState() => _DoctorPatientListScreenState();
}

class _DoctorPatientListScreenState extends State<DoctorPatientListScreen> {
  final ClinicalRepository _repository = ClinicalRepository();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allPatients = [];
  List<dynamic> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchPatients() async {
    print('🚀 [DEBUG] _fetchPatients CALLED');
    try {
      final apps = await _repository.getMyAppointments();
      print('🚀 [DEBUG] Received ${apps.length} appointments from API');
      
      final seen = <dynamic>{};
      final uniquePatients = <Map<String, dynamic>>[];
      
      for (var app in apps) {
        final patientId = app['patient'];
        final status = app['status'];
        final pName = app['patient_display_name'] ?? app['patient_name'];
        print('🚀 [DEBUG] Item: ID=${app['id']}, PatientID=$patientId, Name=$pName, Status=$status');
        
        if (patientId != null && !seen.contains(patientId)) {
          seen.add(patientId);
          uniquePatients.add({
            'id': patientId,
            'name': pName ?? 'Anonymous Patient',
            'lastVisit': app['scheduled_at'],
          });
          print('🚀 [DEBUG] Added Patient: $pName');
        }
      }

      print('🚀 [DEBUG] Final uniquePatients count: ${uniquePatients.length}');
      if (mounted) {
        setState(() {
          _allPatients = uniquePatients;
          _filteredPatients = uniquePatients;
          _isLoading = false;
        });
        print('🚀 [DEBUG] UI State Updated');
      }
    } catch (e) {
      print('❌ [DEBUG] ERROR in _fetchPatients: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32.r), bottomRight: Radius.circular(32.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Patients', style: GoogleFonts.inter(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16.r)),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search patients...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      icon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchPatients,
                  child: _filteredPatients.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: _filteredPatients.length,
                      itemBuilder: (context, index) {
                        final p = _filteredPatients[index];
                        return GestureDetector(
                          onTap: () => context.push('/doctor/patient-detail', extra: {
                            'patient_id': p['id'],
                            'patient_name': p['name'],
                          }),
                          child: _buildPatientCard(p),
                        );
                      },
                    ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            children: [
              Icon(
                _searchController.text.isEmpty ? Icons.people_outline : Icons.search_off_outlined, 
                size: 64.sp, 
                color: const Color(0xFFCBD5E1)
              ),
              SizedBox(height: 16.h),
              Text(
                _searchController.text.isEmpty ? 'No patients yet' : 'No matching patients', 
                style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)
              ),
              Text(
                _searchController.text.isEmpty ? 'Patients you consult will appear here.' : 'Try a different name.', 
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.sp)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> p) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: Text(p['name'][0].toUpperCase(), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'], style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text('ID: #${p['id']}', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11.sp)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}
