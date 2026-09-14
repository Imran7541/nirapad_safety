import 'package:url_launcher/url_launcher.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/safety_mode.dart';
import '../../data/models/medical_profile_model.dart';

class SmsDispatcher {
  static String buildEmergencyMessage({
    required double latitude,
    required double longitude,
    required String address,
    required int batteryLevel,
    required double speedKmh,
    required SafetyMode mode,
    MedicalProfileModel? medicalProfile,
    bool isDuress = false,
  }) {
    final buffer = StringBuffer();
    if (isDuress) {
      buffer.writeln('🚨 [গোপন সংকেত/DURESS SOS] আমি বিপদে পড়েছি!');
    } else {
      buffer.writeln('🚨 [EMERGENCY SOS] জরুরি সাহায্য প্রয়োজন!');
    }
    
    buffer.writeln('মোড: ${mode.titleBn}');
    buffer.writeln('অবস্থান: https://maps.google.com/?q=$latitude,$longitude');
    if (address.isNotEmpty) {
      buffer.writeln('ঠিকানা: $address');
    }
    buffer.writeln('ব্যাটারি: $batteryLevel% | গতি: ${speedKmh.toStringAsFixed(1)} km/h');
    
    if (medicalProfile != null && medicalProfile.bloodGroup.isNotEmpty) {
      buffer.writeln('মেডিকেল: রক্ত ${medicalProfile.bloodGroup}');
      if (medicalProfile.allergies.isNotEmpty) {
        buffer.writeln('এলার্জি: ${medicalProfile.allergies}');
      }
    }
    buffer.write('দয়া করে অবিলম্বে যোগাযোগ বা সাহায্য পাঠান!');
    return buffer.toString();
  }

  static Future<bool> sendSmsToContact({
    required ContactModel contact,
    required String message,
  }) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: contact.phoneNumber,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> dialNumber(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(telUri)) {
        return await launchUrl(telUri);
      }
    } catch (_) {}
    return false;
  }
}
