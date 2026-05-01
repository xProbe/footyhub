import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light/light.dart';

/// Sensor cahaya ambien: lux kurang dari 10 mengaktifkan dark mode di MaterialApp.
class ThemeModeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  StreamSubscription<int>? _luxSub;

  @override
  void onInit() {
    super.onInit();
    try {
      _luxSub = Light().lightSensorStream.listen((lux) {
        final dark = lux < 10;
        final next = dark ? ThemeMode.dark : ThemeMode.light;
        if (themeMode.value != next) themeMode.value = next;
      });
    } catch (_) {
      // Emulator / desktop: tetap light
    }
  }

  @override
  void onClose() {
    _luxSub?.cancel();
    super.onClose();
  }
}
