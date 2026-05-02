import 'dart:async';
import 'package:get/get.dart';
import 'package:light/light.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:flutter/foundation.dart' as foundation;

class DashboardController extends GetxController {
  var tabIndex = 0.obs;
  
  // Sensors
  Light? _light;
  StreamSubscription? _lightSubscription;
  bool _hasWarnedLight = false;

  StreamSubscription? _proximitySubscription;
  var isProximityNear = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initLightSensor();
    _initProximitySensor();
  }

  void _initLightSensor() {
    try {
      _light = Light();
      _lightSubscription = _light?.lightSensorStream.listen((luxValue) {
        if (luxValue < 5 && !_hasWarnedLight) {
          _hasWarnedLight = true;
          Get.snackbar(
            'Peringatan Sensor Cahaya',
            'Kondisi sekitar sangat gelap ($luxValue lux). Jaga jarak mata Anda dari layar!',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
        } else if (luxValue > 20) {
          _hasWarnedLight = false;
        }
      });
    } catch (_) {}
  }

  void _initProximitySensor() {
    try {
      _proximitySubscription = ProximitySensor.events.listen((int event) {
        // value > 0 means near
        isProximityNear.value = (event > 0);
      });
    } catch (_) {}
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  @override
  void onClose() {
    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();
    super.onClose();
  }
}
