import 'package:hive_flutter/hive_flutter.dart';

class HiveProvider {
  static const String userBoxName = 'userBox';
  static const String gameBoxName = 'gameBox';

  // ==========================================
  // 1. DATA USER (Primary Key: Email)
  // ==========================================
  static Future<void> saveUser(
    String email,
    Map<String, dynamic> userData,
  ) async {
    var box = Hive.box(userBoxName);
    await box.put(email, userData);
  }

  static Map<dynamic, dynamic>? getUser(String email) {
    var box = Hive.box(userBoxName);
    return box.get(email);
  }

  // ==========================================
  // 2. DATA GAME (Relasi dengan Email)
  // ==========================================
  // Perhatikan: Sekarang kita wajib memasukkan 'email'
  static void saveHighScore(String email, int score) {
    var box = Hive.box(gameBoxName);

    // Kuncinya menjadi unik, contoh: 'highScore_admin@gmail.com'
    String uniqueKey = 'highScore_$email';

    int currentHighScore = box.get(uniqueKey, defaultValue: 0);
    if (score > currentHighScore) {
      box.put(uniqueKey, score);
    }
  }

  static int getHighScore(String email) {
    var box = Hive.box(gameBoxName);
    return box.get('highScore_$email', defaultValue: 0);
  }

  // ==========================================
  // 3. SETTING BIOMETRIK (Relasi dengan Email)
  // ==========================================
  static void saveBiometricStatus(String email, bool isEnabled) {
    var box = Hive.box(userBoxName);
    box.put('biometric_$email', isEnabled);
  }

  static bool getBiometricStatus(String email) {
    var box = Hive.box(userBoxName);
    return box.get('biometric_$email', defaultValue: false);
  }

  // ==========================================
  // 4. DATA TESTIMONI (Relasi dengan Email)
  // ==========================================
  static void saveTestimonial(String email, String content, int rating) {
    var box = Hive.box(userBoxName);
    box.put('testimonial_content_$email', content);
    box.put('testimonial_rating_$email', rating);
  }

  static String getTestimonialContent(String email) {
    var box = Hive.box(userBoxName);
    return box.get('testimonial_content_$email', defaultValue: '');
  }

  // ==========================================
  // 5. DATA FOTO PROFIL (Relasi dengan Email)
  // ==========================================
  static void saveProfileImagePath(String email, String path) {
    var box = Hive.box(userBoxName);
    box.put('profile_image_$email', path);
  }

  static String getProfileImagePath(String email) {
    var box = Hive.box(userBoxName);
    return box.get('profile_image_$email', defaultValue: '');
  }
}
