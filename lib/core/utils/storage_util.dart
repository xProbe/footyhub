import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class StorageUtil {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserNim = 'userNim';
  static const String keyUserName = 'userName';
  static const String keyUsername = 'username';
  static const String keyJwtToken = 'jwtToken';
  static const String keyLastLoginUsername = 'lastLoginUsername';

  static Future<void> saveJwtSession({
    required String token,
    required String username,
    required String name,
    required String nim,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyJwtToken, token);
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyUserName, name);
    await prefs.setString(keyUserNim, nim);
    await prefs.setString(keyLastLoginUsername, username);
  }

  /// Kompatibilitas lama — JWT session.
  static Future<void> saveLoginSession(
    String emailOrUsername,
    String nim,
    String name,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUsername, emailOrUsername);
    await prefs.setString(keyUserName, name);
    await prefs.setString(keyUserNim, nim);
    await prefs.setString(keyLastLoginUsername, emailOrUsername);
  }

  static Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyJwtToken);
  }

  static Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUsername);
  }

  /// Alias untuk modul yang masih memakai nama "email" sebagai kunci akun lokal.
  static Future<String?> getLoggedInEmail() => getLoggedInUsername();

  static Future<String?> getLastLoginUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastLoginUsername);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<bool> hasValidSession() async {
    final token = await getJwtToken();
    if (token == null || token.isEmpty) return false;
    try {
      if (JwtDecoder.isExpired(token)) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyJwtToken);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserNim);
  }
}
