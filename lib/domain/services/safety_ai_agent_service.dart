import 'dart:convert';
import 'package:http/http.dart' as http;

class SafetyAiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> quickActions; // e.g. ['call_999', 'trigger_sos', 'find_blood']

  SafetyAiMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.quickActions = const [],
  }) : timestamp = timestamp ?? DateTime.now();
}

class SafetyAiAgentService {
  final String? apiKey;
  static const String _model = 'gemini-2.5-flash';

  SafetyAiAgentService({this.apiKey});

  Future<SafetyAiMessage> askSafetyAgent(String userQuery) async {
    // 1. Try Gemini API if API key is present
    if (apiKey != null && apiKey!.isNotEmpty) {
      try {
        final response = await _queryGemini(userQuery);
        return response;
      } catch (_) {
        // Fallback to offline rule engine
      }
    }

    // 2. Offline Crisis Knowledge Engine (Guaranteed zero-failure even without internet or API key)
    return _offlineCrisisEngine(userQuery);
  }

  Future<SafetyAiMessage> _queryGemini(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
    );

    const systemPrompt = '''
You are "Nirapad AI", an expert Emergency First-Aid and Crisis Assistant for Bangladesh.
Respond in clear, empathetic, action-oriented Bengali (or English if prompted in English).
Rules:
1. Prioritize immediate life safety in concise bullet points.
2. If severe trauma, bleeding, unconsciousness, or crime is mentioned, advise calling 999 or triggering SOS immediately.
3. Keep instructions simple, step-by-step, and calm.
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': '$systemPrompt\n\nইউজারের প্রশ্ন: $prompt'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 800,
      }
    });

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      final actions = _detectActions('$prompt $text');
      return SafetyAiMessage(text: text, isUser: false, quickActions: actions);
    } else {
      throw Exception('Gemini API error: ${res.statusCode}');
    }
  }

  SafetyAiMessage _offlineCrisisEngine(String query) {
    final q = query.toLowerCase();
    String reply = '';
    List<String> actions = [];

    if (q.contains('রক্ত') || q.contains('bleeding') || q.contains('কাটা')) {
      reply = '''🩸 তীব্র রক্তপাত বন্ধের তাৎক্ষণিক পদক্ষেপ:
১. পরিষ্কার কাপড় বা গজ দিয়ে ক্ষতস্থানে সরাসরি শক্ত চাপ (Direct Pressure) দিয়ে ধরে রাখুন।
২. আঘাতপ্রাপ্ত স্থানটি সম্ভব হলে হার্টের লেভেলের চেয়ে উঁচুতে তুলে রাখুন।
৩. রক্ত বন্ধ না হলে ওপর দিয়ে কাপড়টি চেপে ব্যান্ডেজ দিয়ে শক্ত করে বাঁধুন।
৪. বরফ বা মাটি ক্ষতে লাগাবেন না।
৫. রক্তপাত অতিরিক্ত হলে অবিলম্বে ৯৯৯-এ কল করুন বা হাসপাতালে যান।''';
      actions = ['call_999', 'trigger_sos', 'find_blood'];
    } else if (q.contains('পোড়া') || q.contains('burn') || q.contains('আগুন')) {
      reply = '''🔥 আগুনে পোড়ার ফার্স্ট এইড:
১. সাথে সাথে সাধারণ তাপমাত্রার পরিষ্কার পানি দিয়ে পোড়া অংশটি অন্তত ১৫-২০ মিনিট একটানা ধুয়ে ফেলুন।
২. বরফ, পেস্ট, ডিম বা তেল কখনো পোড়া ক্ষতে লাগাবেন না—এতে ইনফেকশন বেড়ে যায়।
৩. আলতো করে শুকনো পরিষ্কার জীবাণুমুক্ত কাপড় বা প্লাস্টিক র‍্যাপ দিয়ে ঢেকে রাখুন।
৪. বড় ফোসকা পড়লে তা ফাটাবেন না। দ্রুত নিকটস্থ বার্ন ইউনিটে যান।''';
    } else if (q.contains('হার্ট') || q.contains('heart') || (q.contains('বুকে') && q.contains('ব্যথা')) || q.contains('শ্বাসকষ্ট') || q.contains('স্ট্রোক')) {
      reply = '''🫀 হার্ট অ্যাটাক ও স্ট্রোকের জরুরি লক্ষণ ও করণীয়:
• লক্ষণ: বুকে তীব্র চাপ বা ব্যথা (যা বাম হাত, পিঠ বা চোয়ালে ছড়ায়), শ্বাসকষ্ট ও ঘাম হওয়া।
• করণীয়:
১. রোগীকে অবিলম্বে আরামদায়কভাবে বসিয়ে দিন (শুয়ে না রেখে আধা-বসা পজিশন)।
২. টাইট জামাকাপড় ঢিলেঢালা করে দিন এবং বাতাস চলাচলের ব্যবস্থা করুন।
৩. রোগী কথা বলতে পারলে ডিসপিরিন/অ্যাসপিরিন (৩০০ মিগ্রা) চিবিয়ে খেতে দিন।
৪. রোগীকে একা ছাড়বেন না, প্রতি সেকেন্ড গুরুত্বপূর্ণ—তৎক্ষণাৎ ৯৯৯ অ্যাম্বুলেন্স কল করুন!''';
      actions = ['call_999', 'trigger_sos'];
    } else if (q.contains('বাইক') || q.contains('এক্সিডেন্ট') || q.contains('দুর্ঘটনা') || q.contains('ভাঙা')) {
      reply = '''🏍️ বাইক বা সড়ক দুর্ঘটনার জরুরি প্রোটোকল:
১. হেলমেট জোর করে খুলবেন না যদি ঘাড়ে আঘাতের আশঙ্কা থাকে।
২. আহত ব্যক্তিকে অপ্রয়োজনে নাড়াচাড়া করবেন না (মেরুদণ্ডে বা হাড়ে ফ্র্যাকচার থাকতে পারে)।
৩. রক্তপাত থাকলে কাপড় চেপে ধরে রক্ত বন্ধ করুন।
৪. রোগীকে পানি বা খাবার জোর করে খাওয়াবেন না (অচেতন হলে শ্বাসনালীতে যেতে পারে)।
৫. হাইওয়ে পুলিশ (০১৩২০০১০০০০) বা ৯৯৯ অ্যাম্বুলেন্সে তাৎক্ষণিক কল দিন।''';
      actions = ['call_999', 'highway_police', 'trigger_sos'];
    } else if (q.contains('পিছু') || q.contains('ছিনতাই') || q.contains('ভয়') || q.contains('রাস্তায়') || q.contains('stalk')) {
      reply = '''🛡️ রাস্তায় বিপদ বা পিছু নেওয়ার তাৎক্ষণিক সুরক্ষা কৌশল:
১. শান্ত থাকুন, দ্রুত কোনো জনাকীর্ণ দোকান, ফার্মেসি বা রেস্তোরাঁয় ঢুকে পড়ুন।
২. 'নিরাপদ' অ্যাপের "ফেক কল" বাটনটি চালু করে ফোনে জোরে কথা বলার ভান করুন ("বাবা, আমি মোড়েই আছি, তুমি আসছ?").
৩. আলো ছাড়া নির্জন গলি এড়িয়ে চলুন।
৪. বিপদ ঘনীভূত হলে ফোনের ভলিউম বাটন দিয়ে বা ঝাঁকিয়ে সিক্রেট এসওএস ট্রিগার করুন।
৫. জাতীয় হেল্পলাইন ৯৯৯ বা নারী নির্যাতন প্রতিরোধ হেল্পলাইন ১০৯-এ কল করুন।''';
      actions = ['fake_call', 'trigger_sos', 'call_109'];
    } else if (q.contains('পড়ে') || q.contains('fall') || q.contains('বয়স্ক') || q.contains('মাথা ঘোরা')) {
      reply = '''👴 প্রবীণ ব্যক্তি পড়ে গেলে বা অজ্ঞান হলে করণীয়:
১. সাথে সাথে টেনে তোলার চেষ্টা করবেন না; আগে নিশ্চিত হোন কোমর বা মাথায় আঘাত লেগেছে কি না।
২. শ্বাস-প্রশ্বাস স্বাভাবিক আছে কি না লক্ষ্য করুন।
৩. মাথা সামান্য উঁচুতে রেখে আরামদায়ক অবস্থানে রাখুন।
৪. রক্তচাপ ও ডায়াবেটিস কম বা বেশি হতে পারে, মিষ্টি পানি বা নরম খাবার জ্ঞান ফেরার আগে দেবেন না।
৫. লক-স্ক্রিন মেডিকেল আইডি দেখে পারিবারিক ডাক্তারকে জানান।''';
      actions = ['call_primary', 'trigger_sos'];
    } else {
      reply = '''🤖 আমি নিরাপদ এআই (Nirapad AI Emergency Agent)।
যেকোনো জরুরি স্বাস্থ্য সমস্যা, রক্তপাত, এক্সিডেন্ট, পোড়া বা রাস্তায় নিরাপত্তার প্রাথমিক নিয়ম জানতে আমাকে জিজ্ঞাসা করুন।

উদাহরণ:
• "রক্তপাত বন্ধ করব কীভাবে?"
• "বাইক দুর্ঘটনার পর কী করণীয়?"
• "বুকে ব্যথা বা হার্ট অ্যাটাক হলে কী করব?"
• "রাস্তায় কেউ পিছু নিলে কীভাবে বাঁচব?"''';
    }

    return SafetyAiMessage(text: reply, isUser: false, quickActions: actions);
  }

  List<String> _detectActions(String text) {
    final actions = <String>[];
    final t = text.toLowerCase();
    if (t.contains('৯৯৯') || t.contains('ambulance') || t.contains('ডাক্তার')) actions.add('call_999');
    if (t.contains('রক্ত') || t.contains('blood')) actions.add('find_blood');
    if (t.contains('জরুরি') || t.contains('বিপদ') || t.contains('sos')) actions.add('trigger_sos');
    if (t.contains('ফেক') || t.contains('পিছু')) actions.add('fake_call');
    return actions.toSet().toList();
  }
}
