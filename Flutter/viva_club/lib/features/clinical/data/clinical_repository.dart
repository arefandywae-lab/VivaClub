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
        '/api/clinical/assessments/',
        data: {
          'total_score': totalScore,
          'answers': answers,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to submit assessment';
      } else if (errorData is List && errorData.isNotEmpty) {
        throw errorData[0].toString();
      }
      throw 'Failed to submit assessment';
    }
  }

  Future<List<dynamic>> getDoctors({String? specialty}) async {
    try {
      final response = await _dio.get(
        '/api/clinical/doctors/',
        queryParameters: specialty != null ? {'specialty': specialty} : null,
      );
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to fetch doctors';
      } else if (errorData is List && errorData.isNotEmpty) {
        throw errorData[0].toString();
      }
      throw 'Failed to fetch doctors';
    }
  }

  Future<Map<String, dynamic>> triggerSOS() async {
    try {
      final response = await _dio.post('/api/clinical/sos/');
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to trigger SOS';
      } else if (errorData is List && errorData.isNotEmpty) {
        throw errorData[0].toString();
      }
      throw 'Failed to trigger SOS';
    }
  }

  Future<Map<String, dynamic>> getQueuePosition() async {
    try {
      final response = await _dio.get('/api/clinical/sos/my_position/');
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to get queue position';
      } else if (errorData is List && errorData.isNotEmpty) {
        throw errorData[0].toString();
      }
      throw 'Failed to get queue position';
    }
  }

  Future<List<dynamic>> getTimeSlots(String doctorId) async {
    try {
      final response = await _dio.get(
        '/api/clinical/timeslots/',
        queryParameters: {'doctor_id': doctorId},
      );
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to fetch time slots';
      } else if (errorData is List && errorData.isNotEmpty) {
        throw errorData[0].toString();
      }
      throw 'Failed to fetch time slots';
    }
  }

  Future<Map<String, dynamic>> bookAppointment(String slotId) async {
    try {
      final response = await _dio.post(
        '/api/clinical/appointments/',
        data: {'slot': slotId},
      );
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to book appointment';
      } else if (errorData is List && errorData.isNotEmpty) {
        throw errorData[0].toString();
      }
      throw 'Failed to book appointment';
    }
  }

  Future<Map<String, dynamic>> joinAppointment(String appointmentId) async {
    try {
      final response = await _dio.post('/api/clinical/appointments/$appointmentId/join/');
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to join appointment';
      }
      throw 'Failed to join appointment';
    }
  }

  Future<List<dynamic>> getMyAppointments() async {
    try {
      final response = await _dio.get('/api/clinical/appointments/');
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData['error'] ?? errorData['detail'] ?? 'Failed to fetch appointments';
      } else if (errorData is List && errorData.isNotEmpty) {
        throw errorData[0].toString();
      }
      throw 'Failed to fetch appointments';
    }
  }

  // Doctor Specific Methods
  Future<Map<String, dynamic>> updateDoctorStatus(bool isOnline) async {
    try {
      final response = await _dio.patch('/api/auth/profile/', data: {'is_online': isOnline});
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to update status';
    }
  }

  Future<Map<String, dynamic>> saveOPDNote({
    required String appointmentId,
    required String note,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/clinical/appointments/$appointmentId/',
        data: {'clinical_notes': note},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to save note';
    }
  }

  // Availability Management
  Future<List<dynamic>> getMyTimeSlots() async {
    try {
      final response = await _dio.get('/api/clinical/timeslots/');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to fetch slots';
    }
  }

  Future<Map<String, dynamic>> createTimeSlot({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await _dio.post(
        '/api/clinical/timeslots/',
        data: {
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
        },
      );
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map) {
        throw errorData.values.first.toString();
      }
      throw 'Failed to create time slot';
    }
  }

  Future<void> deleteTimeSlot(String slotId) async {
    try {
      await _dio.delete('/api/clinical/timeslots/$slotId/');
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to delete slot';
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    try {
      await _dio.post('/api/clinical/appointments/$appointmentId/complete/');
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to complete appointment';
    }
  }

  Future<void> completeSOSCall(String sosId) async {
    try {
      await _dio.post('/api/clinical/sos/$sosId/complete/');
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to complete SOS call';
    }
  }
}
