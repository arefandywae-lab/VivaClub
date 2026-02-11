import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class CommunityRepository {
  final DioClient _dioClient = DioClient();

  Future<List<dynamic>> getRooms() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.rooms);
      // If pagination is used, response.data['results']
      if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return response.data;
    } catch (e) {
      throw 'Failed to fetch rooms';
    }
  }

  Future<Map<String, dynamic>> createRoom(String title, String category) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.rooms,
        data: {'title': title, 'category': category},
      );
      return response.data;
    } catch (e) {
      throw 'Failed to create room';
    }
  }

  Future<Map<String, dynamic>> joinRoom(String roomId) async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.joinRoom(roomId));
      return response.data;
    } catch (e) {
      throw 'Failed to join room';
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await _dioClient.dio.post(ApiConstants.leaveRoom(roomId));
    } catch (e) {
      // Silent fail for leave, not critical for user UX
    }
  }
}
