import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../locals/database_helper.dart';

class AuthApiService {
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String password,
    required String name,
    required String nim,
  }) async {
    // Mock network lag
    await Future.delayed(const Duration(milliseconds: 800));
    
    final db = DatabaseHelper.instance;
    final existingUser = await db.getUser(username);
    if (existingUser != null) {
      return {
        'error': 'Username sudah terdaftar',
      };
    }

    await db.insertUser({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'username': username,
      'password_hash': password, // Simple plain text or hash for mock
      'name': name,
      'nim': nim,
      'favorite_team': 'DEFAULT',
      'biometric_enabled': 0,
      'profile_image': '',
      'testimonial': '',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    return {
      'message': 'Registrasi berhasil (SQLite)',
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
    // Mock network lag
    await Future.delayed(const Duration(milliseconds: 800));
    
    final db = DatabaseHelper.instance;
    final user = await db.getUser(username);
    if (user == null) {
      return {
        'error': 'Username tidak ditemukan',
      };
    }

    if (user['password_hash'] != password) {
      return {
        'error': 'Password salah',
      };
    }

    return {
      'message': 'Login berhasil (SQLite)',
      'user': {
        'id': user['id'],
        'username': user['username'],
        'name': user['name'],
        'nim': user['nim'],
      },
      'token': 'mock-token-log-123'
    };
  }
}
