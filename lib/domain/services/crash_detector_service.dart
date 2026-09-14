import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/constants/app_constants.dart';

typedef OnCrashCallback = void Function(double impactGForce);

class CrashDetectorService {
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  final OnCrashCallback onCrashDetected;
  final double crashThresholdG;

  DateTime? _lastImpactTime;

  CrashDetectorService({
    required this.onCrashDetected,
    this.crashThresholdG = AppConstants.crashThresholdG,
  });

  void startListening() {
    stopListening();
    _subscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      final double gX = event.x / 9.80665;
      final double gY = event.y / 9.80665;
      final double gZ = event.z / 9.80665;
      final double totalG = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (totalG > crashThresholdG) {
        final now = DateTime.now();
        if (_lastImpactTime == null || now.difference(_lastImpactTime!).inSeconds > 10) {
          _lastImpactTime = now;
          onCrashDetected(totalG);
        }
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
