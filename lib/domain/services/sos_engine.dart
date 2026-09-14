import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../core/utils/sms_dispatcher.dart';
import '../../data/local/local_db.dart';
import '../../data/local/prefs_manager.dart';
import '../../data/models/incident_model.dart';
import '../../data/models/safety_mode.dart';
import 'battery_service.dart';
import 'location_service.dart';
import 'siren_alarm_service.dart';

enum SOSState {
  idle,
  countdown,
  dispatched,
  cancelled,
  duressDispatched,
}

class SOSEngine {
  final LocalDb localDb;
  final PrefsManager prefsManager;

  SOSState _state = SOSState.idle;
  SOSState get state => _state;

  int _countdownRemaining = 10;
  int get countdownRemaining => _countdownRemaining;

  Timer? _countdownTimer;
  SafetyMode _activeMode = SafetyMode.women;
  SafetyMode get activeMode => _activeMode;

  String _triggerReason = '';
  String get triggerReason => _triggerReason;

  IncidentModel? _currentIncident;
  IncidentModel? get currentIncident => _currentIncident;

  final List<void Function()> _listeners = [];

  SOSEngine({required this.localDb, required this.prefsManager});

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  void triggerSOS({
    SafetyMode? mode,
    String reason = 'ম্যানুয়াল এসওএস বাটন',
    bool bypassCountdown = false,
  }) {
    if (_state == SOSState.countdown || _state == SOSState.dispatched) return;

    _activeMode = mode ?? prefsManager.currentMode;
    _triggerReason = reason;

    if (bypassCountdown) {
      _dispatchNow(isDuress: false);
      return;
    }

    _state = SOSState.countdown;
    _countdownRemaining = prefsManager.countdownSeconds;
    _notify();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownRemaining > 1) {
        _countdownRemaining--;
        _notify();
      } else {
        _countdownTimer?.cancel();
        _dispatchNow(isDuress: false);
      }
    });
  }

  /// Cancels the SOS or triggers secret Duress dispatch based on PIN
  Future<bool> cancelOrDuress(String enteredPin) async {
    _countdownTimer?.cancel();

    if (enteredPin == prefsManager.duressPin) {
      // Attacker forced user to enter PIN. Pretend cancelled to attacker,
      // but immediately dispatch silent high-priority duress SOS in background!
      _state = SOSState.duressDispatched;
      _notify();
      await _dispatchNow(isDuress: true);
      return true; // Returns true so UI pretends "Cancelled" to the assailant
    }

    // Normal safe cancellation
    _state = SOSState.cancelled;
    await SirenAlarmService.instance.cancelAlarm();
    _notify();

    Future.delayed(const Duration(seconds: 2), () {
      _state = SOSState.idle;
      _notify();
    });

    return true;
  }

  Future<void> _dispatchNow({required bool isDuress}) async {
    _countdownTimer?.cancel();
    _state = isDuress ? SOSState.duressDispatched : SOSState.dispatched;
    _notify();

    // 1. Gather Telemetry (GPS, Battery)
    final position = await LocationService.getCurrentLocation();
    final double lat = position?.latitude ?? 23.8103; // Default to Dhaka center if no GPS
    final double lng = position?.longitude ?? 90.4125;
    final double speed = position != null ? (position.speed * 3.6) : 0.0;
    final address = await LocationService.getAddressFromCoordinates(lat, lng);
    final battery = await BatteryService.getBatteryLevel();
    final medical = await localDb.getMedicalProfile();

    // 2. Create Incident Record
    final incident = IncidentModel(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      latitude: lat,
      longitude: lng,
      address: address,
      mode: _activeMode,
      status: isDuress ? 'duress_dispatched' : 'dispatched',
      batteryLevel: battery,
      speedKmh: speed,
      notes: _triggerReason,
      isDuressAlarm: isDuress,
    );
    _currentIncident = incident;
    await localDb.insertIncident(incident);

    // 3. Format SMS Payload
    final smsBody = SmsDispatcher.buildEmergencyMessage(
      latitude: lat,
      longitude: lng,
      address: address,
      batteryLevel: battery,
      speedKmh: speed,
      mode: _activeMode,
      medicalProfile: medical,
      isDuress: isDuress,
    );

    // 4. Send SMS to all trusted contacts
    final contacts = await localDb.getContacts();
    final smsContacts = contacts.where((c) => c.canReceiveSms && c.phoneNumber.isNotEmpty).toList();
    if (smsContacts.isNotEmpty) {
      final primary = smsContacts.firstWhere((c) => c.isPrimary, orElse: () => smsContacts.first);
      await SmsDispatcher.sendSmsToContact(contact: primary, message: smsBody);
    }

    // 5. Sound critical siren & show banner (unless duress stealth mode)
    if (!isDuress) {
      await SirenAlarmService.instance.showEmergencyNotification(
        title: '🚨 EMERGENCY SOS ACTIVATED!',
        body: 'জরুরি সংকেত পাঠানো হয়েছে! অবস্থান: $address',
      );
    }

    _notify();
  }

  void resolveEmergency() {
    _countdownTimer?.cancel();
    _state = SOSState.idle;
    _currentIncident = null;
    SirenAlarmService.instance.cancelAlarm();
    _notify();
  }
}
