import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory DioClient() {
    return _instance;
  }

  /// Call this before login/register to make sure no stale token is sent
  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if this is a public endpoint (no auth needed)
          final fullUrl = options.uri.toString();
          final isPublic =
              fullUrl.contains('/auth/login') ||
              fullUrl.contains('/auth/register');

          if (isPublic) {
            // Remove any Authorization header that might have been set
            options.headers.remove('Authorization');
          } else {
            final token = await _storage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Clear stale tokens on any 401
            await _storage.delete(key: 'access_token');
            await _storage.delete(key: 'refresh_token');
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  Dio get dio => _dio;
}
