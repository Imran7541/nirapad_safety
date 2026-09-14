import 'package:shared_preferences/shared_preferences.dart';
import '../models/safety_mode.dart';

class PrefsManager {
  static const String _keyMode = 'current_safety_mode';
  static const String _keyShakeTrigger = 'shake_trigger_enabled';
  static const String _keyCrashDetection = 'crash_detection_enabled';
  static const String _keySafePin = 'safe_cancel_pin';
  static const String _keyDuressPin = 'duress_secret_pin';
  static const String _keyCountdownSec = 'countdown_seconds';
  static const String _keyAutoCall999 = 'auto_call_999';
  static const String _keySmsTemplate = 'sms_custom_template';
  static const String _keyAudioSnapshot = 'record_audio_snapshot';

  final SharedPreferences _prefs;

  PrefsManager(this._prefs);

  static Future<PrefsManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsManager(prefs);
  }

  SafetyMode get currentMode {
    final name = _prefs.getString(_keyMode);
    return SafetyMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => SafetyMode.women,
    );
  }

  Future<bool> setMode(SafetyMode mode) {
    return _prefs.setString(_keyMode, mode.name);
  }

  bool get isShakeTriggerEnabled => _prefs.getBool(_keyShakeTrigger) ?? true;
  Future<bool> setShakeTriggerEnabled(bool value) => _prefs.setBool(_keyShakeTrigger, value);

  bool get isCrashDetectionEnabled => _prefs.getBool(_keyCrashDetection) ?? true;
  Future<bool> setCrashDetectionEnabled(bool value) => _prefs.setBool(_keyCrashDetection, value);

  String get safePin => _prefs.getString(_keySafePin) ?? '1234';
  Future<bool> setSafePin(String pin) => _prefs.setString(_keySafePin, pin);

  String get duressPin => _prefs.getString(_keyDuressPin) ?? '9999';
  Future<bool> setDuressPin(String pin) => _prefs.setString(_keyDuressPin, pin);

  int get countdownSeconds => _prefs.getInt(_keyCountdownSec) ?? 10;
  Future<bool> setCountdownSeconds(int sec) => _prefs.setInt(_keyCountdownSec, sec);

  bool get isAutoCall999Enabled => _prefs.getBool(_keyAutoCall999) ?? false;
  Future<bool> setAutoCall999Enabled(bool value) => _prefs.setBool(_keyAutoCall999, value);

  bool get isAudioSnapshotEnabled => _prefs.getBool(_keyAudioSnapshot) ?? true;
  Future<bool> setAudioSnapshotEnabled(bool value) => _prefs.setBool(_keyAudioSnapshot, value);

  String get customSmsTemplate => _prefs.getString(_keySmsTemplate) ?? 
      'EMERGENCY SOS! আমি বিপদে পড়েছি। দ্রুত সাহায্য পাঠান। অবস্থান: ';
  Future<bool> setCustomSmsTemplate(String t) => _prefs.setString(_keySmsTemplate, t);
}
