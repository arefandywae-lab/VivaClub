import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://vivaclub-production.up.railway.app';
    }
    if (kReleaseMode) {
      return 'https://vivaclub-production.up.railway.app';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Local dev for emulator
    }
    // For physical iOS devices in debug mode, we point to Railway
    // because localhost doesn't work.
    return 'https://vivaclub-production.up.railway.app';
  }

  // Auth Endpoints
  static const String login = '/api/auth/login/';
  static const String register = '/api/auth/register/';
  static const String profile = '/api/auth/profile/';

  // Community Endpoints
  static const String rooms = '/api/community/rooms/';
  static String joinRoom(String roomId) => '/api/community/rooms/$roomId/join/';
  static String leaveRoom(String roomId) =>
      '/api/community/rooms/$roomId/leave/';
  static String inviteSpeaker(String roomId) =>
      '/api/community/rooms/$roomId/invite/';

  // Booking Endpoints
  static const String appointments = '/api/bookings/slots/';
  static String reserveSlot(String slotId) =>
      '/api/bookings/slots/$slotId/reserve/';
  static String confirmSlot(String slotId) =>
      '/api/bookings/slots/$slotId/confirm/';
}
