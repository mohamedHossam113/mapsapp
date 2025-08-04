// services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/models/auth_response.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8010/api', // ✅ ADD THIS
    // baseUrl: 'http://127.0.0.1:8010/api',

    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  var baseUrl = 'http://10.0.2.2:8010/api';
  // var webbaseUrl = 'http://127.0.0.1:8010/api';

  Future<AuthResponse> login(String username, String password) async {
    final response = await _dio.post('/user/login', data: {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(response.data);

      // ✅ احفظ التوكن باستخدام flutter_secure_storage
      await TokenManager.saveToken(authResponse.token);

      return authResponse;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<AuthResponse> registerUser(String username, String email,
      String password, String confirmPassword) async {
    try {
      final response = await _dio.post('$baseUrl/user/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'passwordConfirm': confirmPassword,
      });
      print('📤 Sending Register Request with data$response:');
      print({
        'username': username,
        'email': email,
        'password': password,
        'passwordConfirm': confirmPassword,
      });

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Print full response from API
      if (e.response != null) {
        print('❌ Dio error: ${e.response?.statusCode}');
        print('❌ Dio data: ${e.response?.data}');
      } else {
        print('❌ Dio error without response: $e');
      }

      throw Exception(
          'Registration failed: ${e.response?.data?['message'] ?? e.message}');
    }
  }
}
