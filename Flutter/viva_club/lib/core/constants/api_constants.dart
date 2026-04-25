class ApiConstants {
  // Point to the live VPS backend for all builds
  static String get baseUrl {
    return 'https://vivaclubs.site';
  }

  // Auth Endpoints
  static const String login = '/api/auth/login/';
  static const String register = '/api/auth/register/';
  static const String profile = '/api/auth/profile/';
  static const String forgotPassword = '/api/auth/forgot-password/';

  // Community Endpoints
  static const String rooms = '/api/community/rooms/';
  static const String reports = '/api/community/reports/';
  static const String trustScore = '/api/community/trust-score/me/';
  static const String ghostProfileMe = '/api/community/ghosts/me/';
  static const String blocks = '/api/community/blocks/';
  static String blockUser(String userId) =>
      '/api/community/blocks/$userId/unblock/';
  static String joinRoom(String roomId) => '/api/community/rooms/$roomId/join/';
  static String leaveRoom(String roomId) =>
      '/api/community/rooms/$roomId/leave/';
  static String inviteSpeaker(String roomId) =>
      '/api/community/rooms/$roomId/invite/';
  static String demoteSpeaker(String roomId) =>
      '/api/community/rooms/$roomId/demote-speaker/';
  static String muteParticipant(String roomId) =>
      '/api/community/rooms/$roomId/mute-participant/';
  static String kickParticipant(String roomId) =>
      '/api/community/rooms/$roomId/kick-participant/';
  static String promoteModerator(String roomId) =>
      '/api/community/rooms/$roomId/promote-moderator/';
  static String demoteModerator(String roomId) =>
      '/api/community/rooms/$roomId/demote-moderator/';

  // Booking Endpoints
  static const String appointments = '/api/bookings/slots/';
  static String reserveSlot(String slotId) =>
      '/api/bookings/slots/$slotId/reserve/';
  static String confirmSlot(String slotId) =>
      '/api/bookings/slots/$slotId/confirm/';
}
