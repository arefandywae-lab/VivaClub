import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DioClient _dioClient = DioClient();

  bool _initialized = false;

  Future<void> initialize() async {
    debugPrint('🔔🔔🔔 NOTIFICATION SERVICE: STARTING INITIALIZATION...');
    if (_initialized) return;

    try {
      // Small delay to ensure everything else is ready
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('🔔 NOTIFICATION SERVICE: REQUESTING PERMISSION...');
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('🔔 NOTIFICATION SERVICE: STATUS -> ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _initialized = true;
        
        String? token;
        try {
          // Check if we're on iOS and not on a real device
          if (Platform.isIOS) {
            // On iOS, sometimes we need to wait for APNS token
            // But on simulator, it will always fail. We handle it here.
            token = await _fcm.getToken();
          } else {
            token = await _fcm.getToken();
          }
        } catch (e) {
          debugPrint('⚠️ FCM TOKEN ERROR (Expected on Simulator): $e');
        }

        if (token != null) {
          debugPrint('🔔 FCM TOKEN SUCCESS: $token');
          await _saveTokenToBackend(token);
        } else {
          debugPrint('ℹ️ NOTIFICATION SERVICE: NO TOKEN (Skipping for now)');
        }

        _fcm.onTokenRefresh.listen(_saveTokenToBackend);
      }
    } catch (e) {
      if (e.toString().contains('apns-token-not-set')) {
        debugPrint('ℹ️ FCM: APNS token not set (iOS Simulator behavior)');
      } else {
        debugPrint('❌ NOTIFICATION SERVICE ERROR: $e');
      }
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    try {
      await _dioClient.dio.post(
        '/api/users/device-tokens/',
        data: {
          'token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      debugPrint('FCM TOKEN SAVED TO BACKEND SUCCESSFULLY');
    } catch (e) {
      debugPrint('FAILED TO SAVE FCM TOKEN TO BACKEND: $e');
    }
  }
}
