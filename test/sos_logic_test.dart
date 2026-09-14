import 'package:flutter_test/flutter_test.dart';
import 'package:nirapad_safety/core/utils/sms_dispatcher.dart';
import 'package:nirapad_safety/data/models/contact_model.dart';
import 'package:nirapad_safety/data/models/incident_model.dart';
import 'package:nirapad_safety/data/models/medical_profile_model.dart';
import 'package:nirapad_safety/data/models/safety_mode.dart';

void main() {
  group('SmsDispatcher Tests', () {
    test('buildEmergencyMessage formats correct GPS URL and attributes', () {
      const medical = MedicalProfileModel(
        bloodGroup: 'B+',
        allergies: 'পেনিসিলিন',
      );

      final message = SmsDispatcher.buildEmergencyMessage(
        latitude: 23.8103,
        longitude: 90.4125,
        address: 'মিরপুর ১০, ঢাকা',
        batteryLevel: 65,
        speedKmh: 42.5,
        mode: SafetyMode.biker,
        medicalProfile: medical,
        isDuress: false,
      );

      expect(message.contains('EMERGENCY SOS'), isTrue);
      expect(message.contains('https://maps.google.com/?q=23.8103,90.4125'), isTrue);
      expect(message.contains('মিরপুর ১০, ঢাকা'), isTrue);
      expect(message.contains('ব্যাটারি: 65%'), isTrue);
      expect(message.contains('গতি: 42.5 km/h'), isTrue);
      expect(message.contains('রক্ত B+'), isTrue);
      expect(message.contains('এলার্জি: পেনিসিলিন'), isTrue);
    });

    test('buildEmergencyMessage formats Duress stealth header when duress is true', () {
      final message = SmsDispatcher.buildEmergencyMessage(
        latitude: 23.7500,
        longitude: 90.3900,
        address: 'কারওয়ান বাজার',
        batteryLevel: 30,
        speedKmh: 0.0,
        mode: SafetyMode.women,
        isDuress: true,
      );

      expect(message.contains('[গোপন সংকেত/DURESS SOS]'), isTrue);
      expect(message.contains('https://maps.google.com/?q=23.75,90.39'), isTrue);
    });
  });

  group('Models Serialization Tests', () {
    test('ContactModel converts to and from Map accurately', () {
      const contact = ContactModel(
        id: 'cnt_123',
        name: 'আব্দুর রহিম',
        phoneNumber: '01711223344',
        relation: 'পিতা',
        isPrimary: true,
        canReceiveSms: true,
        canReceiveCall: true,
      );

      final map = contact.toMap();
      final restored = ContactModel.fromMap(map);

      expect(restored.id, 'cnt_123');
      expect(restored.name, 'আব্দুর রহিম');
      expect(restored.phoneNumber, '01711223344');
      expect(restored.relation, 'পিতা');
      expect(restored.isPrimary, isTrue);
    });

    test('IncidentModel serializes and deserializes correctly', () {
      final now = DateTime.now();
      final incident = IncidentModel(
        id: 'inc_999',
        timestamp: now,
        latitude: 23.8103,
        longitude: 90.4125,
        address: 'গুলশান ২',
        mode: SafetyMode.elderly,
        status: 'dispatched',
        batteryLevel: 80,
        speedKmh: 0.0,
        notes: 'পড়ে যাওয়া শনাক্তকরণ',
        isDuressAlarm: false,
      );

      final map = incident.toMap();
      final restored = IncidentModel.fromMap(map);

      expect(restored.id, 'inc_999');
      expect(restored.mode, SafetyMode.elderly);
      expect(restored.mapsUrl, 'https://maps.google.com/?q=23.8103,90.4125');
      expect(restored.notes, 'পড়ে যাওয়া শনাক্তকরণ');
    });

    test('MedicalProfileModel summary formats properly', () {
      const profile = MedicalProfileModel(
        fullName: 'করিম সাহেব',
        bloodGroup: 'O+',
        chronicConditions: 'ডায়াবেটিস',
        allergies: 'ডাস্ট',
      );

      final summary = profile.toSmsSummary();
      expect(summary.contains('রক্ত: O+'), isTrue);
      expect(summary.contains('রোগ: ডায়াবেটিস'), isTrue);
      expect(summary.contains('এলার্জি: ডাস্ট'), isTrue);
    });
  });
}
