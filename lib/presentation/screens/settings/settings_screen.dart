import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _safePinCtrl;
  late TextEditingController _duressPinCtrl;
  late TextEditingController _smsTemplateCtrl;

  bool _shakeEnabled = true;
  bool _crashEnabled = true;
  bool _autoCall999 = false;
  int _countdownSeconds = 10;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsManagerProvider);
    _safePinCtrl = TextEditingController(text: prefs.safePin);
    _duressPinCtrl = TextEditingController(text: prefs.duressPin);
    _smsTemplateCtrl = TextEditingController(text: prefs.customSmsTemplate);
    _shakeEnabled = prefs.isShakeTriggerEnabled;
    _crashEnabled = prefs.isCrashDetectionEnabled;
    _autoCall999 = prefs.isAutoCall999Enabled;
    _countdownSeconds = prefs.countdownSeconds;
  }

  @override
  void dispose() {
    _safePinCtrl.dispose();
    _duressPinCtrl.dispose();
    _smsTemplateCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    final prefs = ref.read(prefsManagerProvider);
    await prefs.setSafePin(_safePinCtrl.text.trim());
    await prefs.setDuressPin(_duressPinCtrl.text.trim());
    await prefs.setCustomSmsTemplate(_smsTemplateCtrl.text.trim());
    await prefs.setShakeTriggerEnabled(_shakeEnabled);
    await prefs.setCrashDetectionEnabled(_crashEnabled);
    await prefs.setAutoCall999Enabled(_autoCall999);
    await prefs.setCountdownSeconds(_countdownSeconds);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সেটিংস সফলভাবে সংরক্ষিত হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নিরাপত্তা ও অ্যালার্ট সেটিংস'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Anti-Coercion Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, color: AppColors.emergencyRed),
                      SizedBox(width: 8),
                      Text(
                        'ছিনতাই ও জবরদস্তি প্রতিরোধ (Anti-Coercion)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'কেউ জোরপূর্বক পিন দিতে বাধ্য করলে Duress PIN দিলে ফোন স্বাভাবিক দেখাবে কিন্তু গোপনে পরিবারের কাছে লাইভ লোকেশন ও অডিও ব্যাকগ্রাউন্ডে চলে যাবে।',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const Divider(height: 24),
                  TextField(
                    controller: _safePinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'স্বাভাবিক ক্যানসেল PIN (Safe PIN)',
                      hintText: 'যেমন: 1234',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _duressPinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'গোপন বিপদ PIN (Duress / Hostage PIN)',
                      hintText: 'যেমন: 9999',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sensors & Triggers Section
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('ঝাঁকুনি দিয়ে অ্যালার্ট (Shake Trigger)'),
                  subtitle: const Text('ফোন দ্রুত ৩ বার ঝাঁকালে স্বয়ংক্রিয় এসওএস ট্রিগার'),
                  value: _shakeEnabled,
                  onChanged: (val) => setState(() => _shakeEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('ক্র্যাশ ডিটেকশন (Crash Detection)'),
                  subtitle: const Text('বাইক/যানবাহনের ধাক্কা শনাক্তকরণ'),
                  value: _crashEnabled,
                  onChanged: (val) => setState(() => _crashEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('অটো ৯৯৯ ডায়াল (Auto 999 Call)'),
                  subtitle: const Text('কাউন্টডাউন শেষে স্বয়ংক্রিয়ভাবে ৯৯৯-এ কল পাঠানো'),
                  value: _autoCall999,
                  onChanged: (val) => setState(() => _autoCall999 = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Countdown window
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ভুল অ্যালার্ট বাতিল উইন্ডো: $_countdownSeconds সেকেন্ড',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Slider(
                    value: _countdownSeconds.toDouble(),
                    min: 5,
                    max: 20,
                    divisions: 3,
                    label: '$_countdownSeconds s',
                    onChanged: (v) => setState(() => _countdownSeconds = v.toInt()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // SMS Template Customization
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'এসএমএস বার্তার শুরুতে কাস্টম লেখা',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _smsTemplateCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergencyRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _saveSettings,
            icon: const Icon(Icons.check),
            label: const Text('সেটিংস সংরক্ষণ করুন', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
