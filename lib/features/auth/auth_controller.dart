import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/storage_util.dart';
import '../../data/locals/hive_provider.dart';
import '../../data/services/auth_api_service.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  final LocalAuthentication auth = LocalAuthentication();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<bool> register(
    String name,
    String nim,
    String username,
    String password,
  ) async {
    if (name.isEmpty || nim.isEmpty || username.isEmpty || password.isEmpty) {
      errorMessage.value = 'Semua kolom harus diisi';
      return false;
    }

    isLoading.value = true;
    try {
      final res = await AuthApiService.register(
        username: username.trim(),
        password: password,
        name: name.trim(),
        nim: nim.trim(),
      );
      if (res != null && res['error'] == null && res['token'] != null) {
        errorMessage.value = '';
        return true;
      }
      errorMessage.value =
          res?['error']?.toString() ?? 'Registrasi gagal — cek server & URL auth.';
      return false;
    } catch (e) {
      errorMessage.value = 'Gagal mendaftar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = 'Username dan password harus diisi';
      return false;
    }

    isLoading.value = true;
    try {
      final res = await AuthApiService.login(
        username: username.trim(),
        password: password,
      );
      if (res != null && res['token'] != null) {
        final token = res['token'] as String;
        final user = res['user'] as Map<String, dynamic>? ?? {};
        await StorageUtil.saveJwtSession(
          token: token,
          username: user['username']?.toString() ?? username.trim(),
          name: user['name']?.toString() ?? 'User',
          nim: user['nim']?.toString() ?? '—',
        );
        errorMessage.value = '';
        return true;
      }
      errorMessage.value =
          res?['error']?.toString() ?? 'Login gagal — cek server / kredensial.';
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginWithBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUser = prefs.getString(StorageUtil.keyLastLoginUsername);

      if (lastUser == null || lastUser.isEmpty) {
        errorMessage.value =
            'Login manual dulu, lalu aktifkan biometrik di menu Akun.';
        return false;
      }

      if (!HiveProvider.getBiometricStatus(lastUser)) {
        errorMessage.value =
            'Biometrik belum diaktifkan. Aktifkan di menu Akun setelah login.';
        return false;
      }

      final sessionOk = await StorageUtil.hasValidSession();
      if (!sessionOk) {
        errorMessage.value =
            'Sesi habis. Login dengan password terlebih dahulu.';
        return false;
      }

      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        errorMessage.value = 'Perangkat tidak mendukung biometrik.';
        return false;
      }

      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Autentikasi untuk masuk ke FootyHub',
        biometricOnly: true,
      );

      return didAuthenticate;
    } catch (e) {
      errorMessage.value = 'Biometrik dibatalkan atau gagal.';
      return false;
    }
  }
}
