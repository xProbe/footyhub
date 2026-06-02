import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/storage_util.dart';
import '../../data/locals/database_helper.dart';

class ProfileState {
  final String name;
  final String nim;
  final String profileImagePath;
  final bool isBiometricEnabled;
  final String testimonial;
  final bool isLoading;

  ProfileState({
    this.name = '',
    this.nim = '',
    this.profileImagePath = '',
    this.isBiometricEnabled = false,
    this.testimonial = '',
    this.isLoading = false,
  });

  ProfileState copyWith({
    String? name,
    String? nim,
    String? profileImagePath,
    bool? isBiometricEnabled,
    String? testimonial,
    bool? isLoading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      testimonial: testimonial ?? this.testimonial,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final ImagePicker _picker = ImagePicker();

  ProfileNotifier() : super(ProfileState()) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    state = state.copyWith(isLoading: true);
    final username = await StorageUtil.getLoggedInUsername();
    if (username != null) {
      final user = await DatabaseHelper.instance.getUser(username);
      if (user != null) {
        state = ProfileState(
          name: user['name'] as String? ?? 'User',
          nim: user['nim'] as String? ?? '—',
          profileImagePath: user['profile_image'] as String? ?? '',
          isBiometricEnabled: (user['biometric_enabled'] as int? ?? 0) == 1,
          testimonial: user['testimonial'] as String? ?? '',
          isLoading: false,
        );
        return;
      }
    }
    state = state.copyWith(isLoading: false);
  }

  Future<bool> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
      );

      if (image != null) {
        final username = await StorageUtil.getLoggedInUsername();
        if (username != null) {
          await DatabaseHelper.instance.updateUserField(username, 'profile_image', image.path);
          state = state.copyWith(profileImagePath: image.path);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> submitTpmFeedback(String text) async {
    final username = await StorageUtil.getLoggedInUsername();
    if (username != null) {
      await DatabaseHelper.instance.updateUserField(username, 'testimonial', text);
      state = state.copyWith(testimonial: text);
    }
  }

  Future<bool> toggleBiometric(bool enable) async {
    if (kIsWeb) return false;
    final username = await StorageUtil.getLoggedInUsername();
    if (username == null) return false;

    if (enable) {
      try {
        bool canCheck = await _localAuth.canCheckBiometrics;
        bool isSupported = await _localAuth.isDeviceSupported();

        if (canCheck && isSupported) {
          bool didAuthenticate = await _localAuth.authenticate(
            localizedReason: 'Aktifkan biometrik untuk login cepat FootyHub',
            biometricOnly: true,
          );

          if (didAuthenticate) {
            await DatabaseHelper.instance.updateUserField(username, 'biometric_enabled', 1);
            state = state.copyWith(isBiometricEnabled: true);
            return true;
          }
        }
      } catch (_) {}
      return false;
    } else {
      await DatabaseHelper.instance.updateUserField(username, 'biometric_enabled', 0);
      state = state.copyWith(isBiometricEnabled: false);
      return true;
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
