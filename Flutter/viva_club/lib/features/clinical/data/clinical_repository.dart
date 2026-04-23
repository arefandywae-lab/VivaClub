import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ClinicalRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> submitAssessment({
    required int totalScore,
    required Map<String, int> answers,
  }) async {
    try {
      final response = await _dio.post(
        '/clinical/assessments/',
        data: {
          'total_score': totalScore,
          'answers': answers,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to submit assessment';
    }
  }

  Future<List<dynamic>> getDoctors({String? specialty}) async {
    try {
      final response = await _dio.get(
        '/clinical/doctors/',
        queryParameters: specialty != null ? {'specialty': specialty} : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to fetch doctors';
    }
  }

  Future<Map<String, dynamic>> triggerSOS() async {
    try {
      final response = await _dio.post('/clinical/sos/');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to trigger SOS';
    }
  }

  Future<Map<String, dynamic>> getQueuePosition() async {
    try {
      final response = await _dio.get('/clinical/sos/my_position/');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to get queue position';
    }
  }

  Future<List<dynamic>> getTimeSlots(String doctorId) async {
    try {
      final response = await _dio.get(
        '/clinical/timeslots/',
        queryParameters: {'doctor_id': doctorId},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to fetch time slots';
    }
  }

  Future<Map<String, dynamic>> bookAppointment(String slotId) async {
    try {
      final response = await _dio.post(
        '/clinical/appointments/',
        data: {'slot': slotId},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to book appointment';
    }
  }

  Future<List<dynamic>> getMyAppointments() async {
    try {
      final response = await _dio.get('/clinical/appointments/');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to fetch appointments';
    }
  }
}
