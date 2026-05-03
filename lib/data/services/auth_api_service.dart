import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../locals/hive_provider.dart';

class AuthApiService {
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String password,
    required String name,
    required String nim,
  }) async {
    // DUMMY REGISTER to bypass API failure
    await Future.delayed(const Duration(milliseconds: 800));
    
    final existingUser = HiveProvider.getUser(username);
    if (existingUser != null) {
      return {
        'error': 'Username sudah terdaftar',
      };
    }

    await HiveProvider.saveUser(username, {
      'username': username,
      'password': password,
      'name': name,
      'nim': nim,
    });

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
    
    final user = HiveProvider.getUser(username);
    if (user == null) {
      return {
        'error': 'Username tidak ditemukan',
      };
    }

    if (user['password'] != password) {
      return {
        'error': 'Password salah',
      };
    }

    return {
      'message': 'Login berhasil (Mock)',
      'user': {
        'id': 1,
        'username': user['username'],
        'name': user['name'],
        'nim': user['nim'],
      },
      'token': 'mock-token-log-123'
    };
  }
}
