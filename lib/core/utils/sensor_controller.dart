import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import '../theme/theme_provider.dart';

class SensorManager {
  final Ref _ref;
  StreamSubscription? _accelerometerSub;
  StreamSubscription? _lightSub;
  
  DateTime _lastShakeTime = DateTime.now();
  final _shakeController = StreamController<void>.broadcast();
  Stream<void> get onShake => _shakeController.stream;

  SensorManager(this._ref) {
    _initAccelerometer();
    _initLightSensor();
  }

  void _initAccelerometer() {
    if (kIsWeb) return;
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
    try {
      _lightSub = Light().lightSensorStream.listen(
        (int lux) {
          // If lux < 10, dim map contrast
          final shouldDim = lux < 10;
          _ref.read(ambientDimmedProvider.notifier).setDimmed(shouldDim);
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void dispose() {
    _accelerometerSub?.cancel();
    _lightSub?.cancel();
    _shakeController.close();
  }
}

final sensorManagerProvider = Provider<SensorManager>((ref) {
  final manager = SensorManager(ref);
  ref.onDispose(() => manager.dispose());
  return manager;
});
