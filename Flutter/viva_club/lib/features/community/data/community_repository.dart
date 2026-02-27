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

  Future<void> inviteSpeaker(String roomId, String identity) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.inviteSpeaker(roomId),
        data: {'identity': identity},
      );
    } catch (e) {
      if (e.runtimeType.toString() == 'DioException') {
        final res = (e as dynamic).response;
        // ignore: avoid_print
        print('Invite Error: ${res?.statusCode} - ${res?.data}');
      }
      throw 'Failed to invite speaker: $e';
    }
  }

  Future<void> muteParticipant(
    String roomId,
    String identity,
    String trackSid,
    bool muted,
  ) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.muteParticipant(roomId),
        data: {'identity': identity, 'track_sid': trackSid, 'muted': muted},
      );
    } catch (e) {
      throw 'Failed to mute participant: $e';
    }
  }

  Future<void> kickParticipant(String roomId, String identity) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.kickParticipant(roomId),
        data: {'identity': identity},
      );
    } catch (e) {
      throw 'Failed to kick participant: $e';
    }
  }

  Future<void> submitReport(
    String reportedUserId,
    String? roomId,
    String reason,
    String description,
  ) async {
    try {
      final data = {
        'reported_user': reportedUserId,
        'reason': reason,
        'description': description,
      };
      if (roomId != null) {
        data['room'] = roomId;
      }

      await _dioClient.dio.post(ApiConstants.reports, data: data);
    } catch (e) {
      throw 'Failed to submit report: $e';
    }
  }

  Future<Map<String, dynamic>> getTrustScore() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.trustScore);
      return response.data;
    } catch (e) {
      throw 'Failed to get trust score';
    }
  }
}
