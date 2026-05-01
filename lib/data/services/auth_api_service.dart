import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthApiService {
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String password,
    required String name,
    required String nim,
  }) async {
    // DUMMY REGISTER to bypass API failure
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'message': 'Registrasi berhasil (Mock)',
      'user': {
        'id': 1,
        'username': username,
        'name': name,
        'nim': nim,
      },
      'token': 'mock-token-reg-123'
    };
  }

  static Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    // DUMMY LOGIN to bypass API failure
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'message': 'Login berhasil (Mock)',
      'user': {
        'id': 1,
        'username': username,
        'name': 'User Dummy',
        'nim': '123456',
      },
      'token': 'mock-token-log-123'
    };
  }
}
