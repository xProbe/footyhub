import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/storage_util.dart';
import '../../data/locals/database_helper.dart';
import '../../data/services/auth_api_service.dart';

class AuthState {
  final bool isLoading;
  final String errorMessage;
  final bool isLoggedIn;
  final String username;
  final String name;
  final String nim;

  AuthState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isLoggedIn = false,
    this.username = '',
    this.name = '',
    this.nim = '',
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
    String? username,
    String? name,
    String? nim,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
      name: name ?? this.name,
      nim: nim ?? this.nim,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthNotifier() : super(AuthState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true);
    final isLogged = await StorageUtil.isLoggedIn();
    if (isLogged) {
      final tokenOk = await StorageUtil.hasValidSession();
      if (tokenOk) {
        final prefs = await SharedPreferences.getInstance();
        state = AuthState(
          isLoggedIn: true,
          username: prefs.getString(StorageUtil.keyUsername) ?? '',
          name: prefs.getString(StorageUtil.keyUserName) ?? '',
          nim: prefs.getString(StorageUtil.keyUserNim) ?? '',
        );
        return;
      }
    }
    state = AuthState();
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final res = await AuthApiService.login(username: username, password: password);
      if (res != null && res['token'] != null) {
        final token = res['token'] as String;
        final user = res['user'] as Map<String, dynamic>? ?? {};
        final name = user['name']?.toString() ?? 'User';
        final nim = user['nim']?.toString() ?? '—';
        
        await StorageUtil.saveJwtSession(
          token: token,
          username: username.trim(),
          name: name,
          nim: nim,
        );

        state = AuthState(
          isLoggedIn: true,
          username: username.trim(),
          name: name,
          nim: nim,
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: res?['error']?.toString() ?? 'Login gagal',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<bool> register(String name, String nim, String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final res = await AuthApiService.register(
        username: username,
        password: password,
        name: name,
        nim: nim,
      );
      if (res != null && res['token'] != null) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: res?['error']?.toString() ?? 'Registrasi gagal',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Gagal mendaftar: $e');
      return false;
    }
  }

  Future<bool> loginWithBiometric() async {
    if (kIsWeb) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Biometric login is not supported in browser environment.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUser = prefs.getString(StorageUtil.keyLastLoginUsername);

      if (lastUser == null || lastUser.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Login manual dulu, lalu aktifkan biometrik di menu Akun.',
        );
        return false;
      }

      final dbUser = await DatabaseHelper.instance.getUser(lastUser);
      final biometricEnabled = dbUser != null && dbUser['biometric_enabled'] == 1;

      if (!biometricEnabled) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Biometrik belum diaktifkan. Aktifkan di menu Akun setelah login.',
        );
        return false;
      }

      final sessionOk = await StorageUtil.hasValidSession();
      if (!sessionOk) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sesi habis. Login dengan password terlebih dahulu.',
        );
        return false;
      }

      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Perangkat tidak mendukung biometrik.',
        );
        return false;
      }

      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Autentikasi untuk masuk ke FootyHub',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        // Reload session state
        final name = prefs.getString(StorageUtil.keyUserName) ?? 'User';
        final nim = prefs.getString(StorageUtil.keyUserNim) ?? '—';
        state = AuthState(
          isLoggedIn: true,
          username: lastUser,
          name: name,
          nim: nim,
        );
        return true;
      }

      state = state.copyWith(isLoading: false, errorMessage: 'Autentikasi gagal.');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Biometrik dibatalkan atau gagal.');
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await DatabaseHelper.instance.clearNewsCache();
    await StorageUtil.clearSession();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
