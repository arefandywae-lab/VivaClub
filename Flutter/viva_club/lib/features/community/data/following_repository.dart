import '../../../core/network/dio_client.dart';

class FollowingRepository {
  final DioClient _dioClient;

  FollowingRepository(this._dioClient);

  /// Follow a ghost profile
  Future<Map<String, dynamic>> followGhost(String ghostId) async {
    try {
      final response = await _dioClient.dio.post(
        '/community/ghosts/$ghostId/follow/',
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to follow ghost: $e');
    }
  }

  /// Unfollow a ghost profile
  Future<Map<String, dynamic>> unfollowGhost(String ghostId) async {
    try {
      final response = await _dioClient.dio.post(
        '/community/ghosts/$ghostId/unfollow/',
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to unfollow ghost: $e');
    }
  }

  /// Get list of ghosts I'm following
  Future<List<Map<String, dynamic>>> getFollowingList() async {
    try {
      final response = await _dioClient.dio.get('/community/following/');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get following list: $e');
    }
  }

  /// Get rooms from followed ghosts (Following Feed)
  Future<Map<String, dynamic>> getFollowingFeed() async {
    try {
      final response = await _dioClient.dio.get('/community/following/feed/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get following feed: $e');
    }
  }

  /// Check if following a ghost
  Future<bool> isFollowing(String ghostId) async {
    try {
      final following = await getFollowingList();
      return following.any((sub) => sub['target'] == ghostId);
    } catch (e) {
      return false;
    }
  }
}
