import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import '../theme/theme_provider.dart';

class SensorManager {
  final Ref _ref;
  StreamSubscription? _accelerometerSub;
  StreamSubscription? _lightSub;
  StreamSubscription? _proximitySub;
  
  DateTime _lastShakeTime = DateTime.now();
  final _shakeController = StreamController<void>.broadcast();
  Stream<void> get onShake => _shakeController.stream;

  SensorManager(this._ref) {
    _initAccelerometer();
    _initLightSensor();
    _initProximitySensor();
  }

  void _initAccelerometer() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) return;
    try {
      _accelerometerSub = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          // Normalize coordinates
          double gX = event.x / 9.80665;
          double gY = event.y / 9.80665;
          double gZ = event.z / 9.80665;
          double gForce = gX * gX + gY * gY + gZ * gZ;

          // If shake threshold is met (e.g. gForce > 2.5)
          if (gForce > 2.5) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTime).inMilliseconds > 2000) {
              _lastShakeTime = now;
              _shakeController.add(null);
            }
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _initLightSensor() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) return;
    try {
      _lightSub = Light().lightSensorStream.listen(
        (int lux) {
          final s = _ref.read(sensorStateProvider);
          if (s.isRealSensor) {
            _ref.read(sensorStateProvider.notifier).setLux(lux);
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _initProximitySensor() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) return;
    try {
      _proximitySub = ProximitySensor.events.listen(
        (int event) {
          final s = _ref.read(sensorStateProvider);
          if (s.isRealProximity) {
            // Usually: 1 = near, 0 = far
            _ref.read(sensorStateProvider.notifier).setNear(event > 0);
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void dispose() {
    _accelerometerSub?.cancel();
    _lightSub?.cancel();
    _proximitySub?.cancel();
    _shakeController.close();
  }
}

final sensorManagerProvider = Provider<SensorManager>((ref) {
  final manager = SensorManager(ref);
  ref.onDispose(() => manager.dispose());
  return manager;
});

final shakeEventProvider = StreamProvider<void>((ref) {
  final manager = ref.watch(sensorManagerProvider);
  return manager.onShake;
});
