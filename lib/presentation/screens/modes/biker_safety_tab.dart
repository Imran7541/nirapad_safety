import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/sms_dispatcher.dart';
import '../../../data/models/safety_mode.dart';
import '../../providers/app_providers.dart';
import '../../widgets/big_sos_button.dart';
import '../sos/active_sos_screen.dart';

class BikerSafetyTab extends ConsumerStatefulWidget {
  const BikerSafetyTab({super.key});

  @override
  ConsumerState<BikerSafetyTab> createState() => _BikerSafetyTabState();
}

class _BikerSafetyTabState extends ConsumerState<BikerSafetyTab> {
  bool _isCrashSensorArmed = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E7490), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.two_wheeler, size: 42, color: Colors.white),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'বাইকার ও হাইওয়ে ক্র্যাশ গার্ড',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'দুর্ঘটনা ও তীব্র ঝাঁকুনি শনাক্ত হলে ১৫ সেকেন্ডে অটো এসওএস',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Big Biker SOS Trigger
          BigSosButton(
            buttonColor: AppColors.bikerSafetyAccent,
            label: 'ক্র্যাশ SOS',
            onTap: () {
              ref.read(sosEngineProvider.notifier).trigger(
                mode: SafetyMode.biker,
                reason: 'বাইকার ম্যানুয়াল ইমার্জেন্সি',
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActiveSosScreen()),
              );
            },
          ),
          const SizedBox(height: 28),

          // Crash Detection Sensor Toggle Card
          Card(
            child: SwitchListTile(
              secondary: Icon(
                _isCrashSensorArmed ? Icons.sensors : Icons.sensors_off,
                color: _isCrashSensorArmed ? AppColors.bikerSafetyAccent : Colors.grey,
              ),
              title: const Text('স্বয়ংক্রিয় ক্র্যাশ সেন্সর'),
              subtitle: Text(
                _isCrashSensorArmed
                    ? 'সক্রিয় (গাড়ির তীব্র ধাক্কা শনাক্ত হলে অ্যালার্ট বাজবে)'
                    : 'নিষ্ক্রিয় রয়েছে',
              ),
              value: _isCrashSensorArmed,
              onChanged: (val) {
                setState(() => _isCrashSensorArmed = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? 'ক্র্যাশ ডিটেকশন চালু করা হয়েছে' : 'ক্র্যাশ সেন্সর বন্ধ করা হয়েছে'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Highway Emergency Numbers
          const Text(
            'হাইওয়ে ও রোড হেল্পলাইন',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    SmsDispatcher.dialNumber(AppConstants.highwayPoliceNumber);
                  },
                  icon: const Icon(Icons.local_police, color: AppColors.bikerSafetyAccent),
                  label: const Text('হাইওয়ে পুলিশ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    SmsDispatcher.dialNumber('999');
                  },
                  icon: const Icon(Icons.emergency, color: Colors.redAccent),
                  label: const Text('অ্যাম্বুলেন্স (৯৯৯)'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
