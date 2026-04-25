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

  Future<List<dynamic>> getMyAppointments() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/clinical/appointments/',
      );
      if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return response.data;
    } catch (e) {
      throw 'Failed to load appointments';
    }
  }

  /// Fetch the authenticated user's trust score
  Future<Map<String, dynamic>> getTrustScore() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.trustScore);
      return response.data;
    } catch (e) {
      return {'score': 100};
    }
  }

  /// Update ghost profile bio (PATCH)
  Future<Map<String, dynamic>> updateBio(String bio) async {
    try {
      final response = await _dioClient.dio.patch(
        ApiConstants.ghostProfileMe,
        data: {'bio': bio},
      );
      return response.data;
    } catch (e) {
      throw 'Failed to update bio';
    }
  }

  /// Get list of blocked users
  Future<List<dynamic>> getBlockedUsers() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.blocks);
      if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return response.data is List ? response.data : [];
    } catch (e) {
      return [];
    }
  }

  /// Block a user
  Future<void> blockUser(String userId) async {
    await _dioClient.dio.post(ApiConstants.blocks, data: {'blocked': userId});
  }

  /// Unblock a user by their user-id (which is the pk in the block object)
  Future<void> unblockUser(String blockedUserId) async {
    await _dioClient.dio.delete(ApiConstants.blockUser(blockedUserId));
  }
}
