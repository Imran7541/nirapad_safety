import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/safety_mode.dart';
import '../../providers/app_providers.dart';
import '../../widgets/big_sos_button.dart';
import '../../widgets/fake_call_dialog.dart';
import '../sos/active_sos_screen.dart';

class WomenSafetyTab extends ConsumerWidget {
  const WomenSafetyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 40, color: Colors.white),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'নারী ও শিক্ষার্থী সুরক্ষা সক্রিয়',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ফোন ৩ বার ঝাঁকালে বা ভলিউম বাটন দিয়ে সিক্রেট অ্যালার্ট যাবে',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Big Pulsing SOS Trigger
          BigSosButton(
            buttonColor: AppColors.womenSafetyAccent,
            label: 'সিক্রেট SOS',
            onTap: () {
              ref.read(sosEngineProvider.notifier).trigger(
                mode: SafetyMode.women,
                reason: 'নারী সুরক্ষা ম্যানুয়াল এসওএস',
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActiveSosScreen()),
              );
            },
          ),
          const SizedBox(height: 32),

          // Tactical Actions
          const Text(
            'কুইক ট্যাকটিক্যাল অ্যাকশন',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Fake Call Escape Card
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEDE9FE),
                child: Icon(Icons.ring_volume, color: AppColors.womenSafetyAccent),
              ),
              title: const Text('ফেক ইনকামিং কল (Fake Call)'),
              subtitle: const Text('বিপদজনক বা অস্বস্তিকর আড্ডা থেকে পালানোর অজুহাত'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.womenSafetyAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FakeCallScreen()),
                  );
                },
                child: const Text('কল বাজান'),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Live Route Share Card
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEDE9FE),
                child: Icon(Icons.share_location, color: AppColors.womenSafetyAccent),
              ),
              title: const Text('লাইভ জার্নি গার্ড (Live Journey)'),
              subtitle: const Text('বাস/সিএনজিতে ওঠার সময় লাইভ লোকেশন লিংক ট্র্যাকিং শেয়ার'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('লাইভ জার্নি ট্র্যাকিং লিংক কন্টাক্টদের শেয়ার করা হচ্ছে...')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
