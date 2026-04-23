import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Clear any stale tokens before logging in
      await _dioClient.clearTokens();
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );

      // Save tokens
      final data = response.data;
      if (data['access'] != null) {
        await _storage.write(key: 'access_token', value: data['access']);
      }
      if (data['refresh'] != null) {
        await _storage.write(key: 'refresh_token', value: data['refresh']);
      }

      return data;
    } catch (e) {
      if (e is DioException) {
        throw e.response?.data['detail'] ?? 'Login failed';
      }
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      // Clear any stale tokens before registering
      await _dioClient.clearTokens();
      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: {'username': username, 'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        // Combine errors into a single string if possible
        if (e.response?.data is Map) {
          String errorMsg = '';
          (e.response?.data as Map).forEach((key, value) {
            errorMsg += '$key: $value\n';
          });
          throw errorMsg.trim();
        }
        throw 'Registration failed';
      }
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profile);
      return response.data;
    } catch (e) {
      throw 'Failed to get profile';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> forgotPassword(String emailOrPhone) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.forgotPassword,
        data: {'identifier': emailOrPhone},
      );
    } catch (e) {
      if (e is DioException) {
        throw e.response?.data['detail'] ?? 'Failed to send reset link';
      }
      throw e.toString();
    }
  }
}
