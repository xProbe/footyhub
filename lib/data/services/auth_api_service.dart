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
    final uri = Uri.parse('${ApiConstants.authBaseUrl}/auth/register');
    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'name': name,
              'nim': nim,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return {'error': res.body};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.authBaseUrl}/auth/login');
    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return {'error': res.body};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
