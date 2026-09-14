import 'package:flutter_test/flutter_test.dart';
import 'package:nirapad_safety/domain/services/safety_ai_agent_service.dart';

void main() {
  group('SafetyAiAgentService Tests', () {
    late SafetyAiAgentService aiService;

    setUp(() {
      aiService = SafetyAiAgentService(); // Without API key, tests robust offline rules
    });

    test('Bleeding question triggers proper first-aid guidance and actions', () async {
      final response = await aiService.askSafetyAgent('প্রচুর রক্তপাত হচ্ছে কি করব?');
      expect(response.text.contains('রক্তপাত বন্ধের তাৎক্ষণিক পদক্ষেপ'), isTrue);
      expect(response.quickActions.contains('call_999'), isTrue);
      expect(response.quickActions.contains('find_blood'), isTrue);
    });

    test('Burn question provides correct burn first-aid instructions', () async {
      final response = await aiService.askSafetyAgent('হাতে গরম চা বা আগুনে পুড়ে গেছে');
      expect(response.text.contains('আগুনে পোড়ার ফার্স্ট এইড'), isTrue);
      expect(response.text.contains('পানি'), isTrue);
      expect(response.text.contains('বরফ'), isTrue);
    });

    test('Stalking question triggers safety strategy and fake call action', () async {
      final response = await aiService.askSafetyAgent('রাতে একজন অপরিচিত লোক পিছু নিয়েছে');
      expect(response.text.contains('রাস্তায় বিপদ বা পিছু নেওয়ার তাৎক্ষণিক সুরক্ষা'), isTrue);
      expect(response.quickActions.contains('fake_call'), isTrue);
    });

    test('Heart attack question triggers 999 and immediate warning', () async {
      final response = await aiService.askSafetyAgent('বুকে তীব্র ব্যথা ও শ্বাসকষ্ট হচ্ছে');
      expect(response.text.contains('হার্ট অ্যাটাক'), isTrue);
      expect(response.quickActions.contains('call_999'), isTrue);
    });
  });
}
