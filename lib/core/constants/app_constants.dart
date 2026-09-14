class AppConstants {
  static const String appName = 'নিরাপদ (Nirapad)';
  static const String appTagline = 'জীবনরক্ষায় অফলাইন-ফার্স্ট সার্বজনীন ইমার্জেন্সি রেসপন্স';
  
  // Bangladesh Emergency Helplines
  static const String nationalEmergencyNumber = '999';
  static const String womenHelplineNumber = '109';
  static const String childHelplineNumber = '1098';
  static const String disasterHelplineNumber = '1090';
  static const String highwayPoliceNumber = '01320010000';

  // Sensor & Detection Thresholds
  static const double shakeThresholdG = 2.8; // G-force for vigorous shake
  static const double crashThresholdG = 4.5; // G-force for sudden bike/vehicle impact
  static const int shakeCountRequired = 3;
  static const int countdownSecondsDefault = 10;
  static const int crashCountdownSeconds = 15;

  // SMS Template Prefix
  static const String defaultSmsPrefix = 'EMERGENCY SOS! আমি বিপদে পড়েছি। আমার বর্তমান অবস্থান:';
}
