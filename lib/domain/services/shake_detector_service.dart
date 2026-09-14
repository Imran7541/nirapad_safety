import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/constants/app_constants.dart';

typedef OnShakeCallback = void Function();

class ShakeDetectorService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final OnShakeCallback onShake;
  final double thresholdG;
  final int shakeCountTarget;

  int _shakeCount = 0;
  DateTime? _firstShakeTime;

  ShakeDetectorService({
    required this.onShake,
    this.thresholdG = AppConstants.shakeThresholdG,
    this.shakeCountTarget = AppConstants.shakeCountRequired,
  });

  void startListening() {
    stopListening();
    _subscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      // Calculate G-force magnitude
      final double gX = event.x / 9.80665;
      final double gY = event.y / 9.80665;
      final double gZ = event.z / 9.80665;
      final double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > thresholdG) {
        final now = DateTime.now();
        if (_firstShakeTime == null || now.difference(_firstShakeTime!).inMilliseconds > 2500) {
          _shakeCount = 1;
          _firstShakeTime = now;
        } else {
          _shakeCount++;
          if (_shakeCount >= shakeCountTarget) {
            _shakeCount = 0;
            _firstShakeTime = null;
            onShake();
          }
        }
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _shakeCount = 0;
    _firstShakeTime = null;
  }
}
