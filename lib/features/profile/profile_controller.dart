import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/storage_util.dart';
import '../../data/locals/hive_provider.dart';
import '../../data/locals/news_database.dart';
import '../../routes/app_routes.dart';

class ProfileController extends GetxController {
  var currentName = 'Loading...'.obs;
  var currentNim = '...'.obs;
  String? accountUsername;

  var currentProfileImagePath = ''.obs;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController testimonialController = TextEditingController();

  var isBiometricEnabled = false.obs;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    accountUsername = await StorageUtil.getLoggedInUsername();

    final prefs = await SharedPreferences.getInstance();
    currentName.value =
        prefs.getString(StorageUtil.keyUserName) ?? 'User Unknown';
    currentNim.value = prefs.getString(StorageUtil.keyUserNim) ?? '000000';

    if (accountUsername != null) {
      isBiometricEnabled.value =
          HiveProvider.getBiometricStatus(accountUsername!);
      currentProfileImagePath.value =
          HiveProvider.getProfileImagePath(accountUsername!);
      testimonialController.text =
          HiveProvider.getTestimonialContent(accountUsername!);
    }
  }

  Future<void> pickProfileImage() async {
    if (accountUsername == null) {
      Get.snackbar('Error', 'Sesi tidak valid.');
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
      );

      if (image != null) {
        currentProfileImagePath.value = image.path;
        HiveProvider.saveProfileImagePath(accountUsername!, image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat gambar galeri.');
    }
  }

  Future<void> submitTpmFeedback() async {
    if (accountUsername == null) return;
    HiveProvider.saveTestimonial(
      accountUsername!,
      testimonialController.text,
      5,
    );
    Get.snackbar(
      'Terkirim',
      'Saran & kesan TPM telah disimpan.',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  Future<void> toggleBiometric(bool value) async {
    if (accountUsername == null) return;

    if (value == true) {
      try {
        bool canCheck = await auth.canCheckBiometrics;
        bool isSupported = await auth.isDeviceSupported();

        if (canCheck && isSupported) {
          bool didAuthenticate = await auth.authenticate(
            localizedReason:
                'Aktifkan biometrik untuk login cepat FootyHub',
            biometricOnly: true,
          );

          if (didAuthenticate) {
            isBiometricEnabled.value = true;
            HiveProvider.saveBiometricStatus(accountUsername!, true);
          } else {
            isBiometricEnabled.value = false;
          }
        } else {
          Get.snackbar('Info', 'Perangkat tidak mendukung biometrik');
          isBiometricEnabled.value = false;
        }
      } catch (e) {
        isBiometricEnabled.value = false;
      }
    } else {
      isBiometricEnabled.value = false;
      HiveProvider.saveBiometricStatus(accountUsername!, false);
    }
  }

  Future<void> logout() async {
    await NewsDatabase.instance.clearAll();
    await StorageUtil.clearSession();
    Get.offAllNamed(Routes.AUTH);
  }
}
