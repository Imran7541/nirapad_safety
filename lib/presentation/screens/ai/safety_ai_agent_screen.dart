import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/sms_dispatcher.dart';
import '../../../data/models/safety_mode.dart';
import '../../../domain/services/safety_ai_agent_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/fake_call_dialog.dart';
import '../community/nearby_responders_screen.dart';
import '../sos/active_sos_screen.dart';

class SafetyAiAgentScreen extends ConsumerStatefulWidget {
  const SafetyAiAgentScreen({super.key});

  @override
  ConsumerState<SafetyAiAgentScreen> createState() => _SafetyAiAgentScreenState();
}

class _SafetyAiAgentScreenState extends ConsumerState<SafetyAiAgentScreen> {
  final List<SafetyAiMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SafetyAiAgentService _aiService;
  bool _isLoading = false;

  final List<String> _quickSuggestions = [
    '🩸 রক্তপাত বন্ধ করার উপায়',
    '🫀 হার্ট অ্যাটাকের লক্ষণ ও করণীয়',
    '🔥 আগুনে পোড়ার ফার্স্ট এইড',
    '🏍️ বাইক দুর্ঘটনার পর কী করণীয়?',
    '🏃‍♀️ রাস্তায় কেউ পিছু নিলে কী করব?',
    '👴 প্রবীণ ব্যক্তি পড়ে গেলে কী করব?',
  ];

  @override
  void initState() {
    super.initState();
    _aiService = SafetyAiAgentService();
    // Initial welcome message
    _messages.add(
      SafetyAiMessage(
        text: 'আসসালামু আলাইকুম! আমি নিরাপদ এআই (Nirapad AI)।\nযে কোনো জরুরি মুহূর্তে প্রাথমিক চিকিৎসা (First-Aid), রক্তপাত, হার্ট অ্যাটাক, পোড়া বা রাস্তায় বিপদ থেকে বাঁচার তাৎক্ষণিক নির্দেশনা পেতে আমাকে প্রশ্ন করুন।',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(SafetyAiMessage(text: query, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _aiService.askSafetyAgent(query);
      if (mounted) {
        setState(() {
          _messages.add(response);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            SafetyAiMessage(
              text: 'দুঃখিত, তথ্য লোড করতে সমস্যা হয়েছে। জরুরি প্রয়োজনে অবিলম্বে ৯৯৯-এ কল করুন।',
              isUser: false,
              quickActions: ['call_999'],
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'call_999':
        SmsDispatcher.dialNumber('999');
        break;
      case 'call_109':
        SmsDispatcher.dialNumber('109');
        break;
      case 'highway_police':
        SmsDispatcher.dialNumber('01320010000');
        break;
      case 'trigger_sos':
        ref.read(sosEngineProvider.notifier).trigger(
          mode: SafetyMode.women,
          reason: 'এআই চ্যাট থেকে ইমার্জেন্সি এসওএস',
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ActiveSosScreen()),
        );
        break;
      case 'fake_call':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FakeCallScreen()),
        );
        break;
      case 'find_blood':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NearbyRespondersScreen()),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildActionChip(String action) {
    String label = '';
    IconData icon = Icons.help;
    Color color = AppColors.emergencyRed;

    switch (action) {
      case 'call_999':
        label = '৯৯৯ কল করুন';
        icon = Icons.call;
        color = Colors.red;
        break;
      case 'call_109':
        label = '১০৯ হেল্পলাইন';
        icon = Icons.support_agent;
        color = Colors.purple;
        break;
      case 'highway_police':
        label = 'হাইওয়ে পুলিশ';
        icon = Icons.local_police;
        color = Colors.cyan.shade700;
        break;
      case 'trigger_sos':
        label = '🚨 SOS অ্যালার্ট পাঠান';
        icon = Icons.warning;
        color = AppColors.emergencyRed;
        break;
      case 'fake_call':
        label = '📱 ফেক কল চালান';
        icon = Icons.phone_callback;
        color = AppColors.womenSafetyAccent;
        break;
      case 'find_blood':
        label = '🩸 রক্তদাতা খুঁজুন';
        icon = Icons.bloodtype;
        color = Colors.red.shade700;
        break;
    }

    return ActionChip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: color,
      onPressed: () => _handleQuickAction(action),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'নিরাপদ AI এজেন্ট',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  'ইমার্জেন্সি ফার্স্ট-এইড ও ক্রাইসিস গাইড',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Question Chips Carousel
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _quickSuggestions.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      onPressed: () => _sendMessage(s),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment:
                        msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.indigo.shade600,
                          child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: msg.isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: msg.isUser
                                    ? AppColors.emergencyRed
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: msg.isUser
                                    ? null
                                    : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: msg.isUser ? Colors.white : null,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (!msg.isUser && msg.quickActions.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: msg.quickActions
                                    .map((act) => _buildActionChip(act))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (msg.isUser) ...[
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF475569),
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('নিরাপদ AI নির্দেশিকা প্রস্তুত করছে...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: _sendMessage,
                    decoration: const InputDecoration(
                      hintText: 'জরুরি প্রশ্ন বা সমস্যা লিখুন...',
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.emergencyRed),
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(_inputController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
