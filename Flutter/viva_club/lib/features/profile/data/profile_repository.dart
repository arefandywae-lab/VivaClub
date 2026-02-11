import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class ProfileRepository {
  final DioClient _dioClient = DioClient();

  /// Fetch the authenticated user's profile (includes ghost_profile)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profile);
      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw 'Session expired. Please log in again.';
      }
      throw 'Failed to load profile';
    }
  }

  /// Fetch the user's appointments (upcoming and past)
  Future<List<dynamic>> getMyAppointments() async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.appointments,
        queryParameters: {'mode': 'mine'},
      );
      if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return response.data;
    } catch (e) {
      throw 'Failed to load appointments';
    }
  }
}
