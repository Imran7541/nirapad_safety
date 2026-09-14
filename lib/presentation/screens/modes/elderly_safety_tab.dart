import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/sms_dispatcher.dart';
import '../../../data/models/safety_mode.dart';
import '../../providers/app_providers.dart';
import '../../widgets/big_sos_button.dart';
import '../medical/medical_id_screen.dart';
import '../sos/active_sos_screen.dart';

class ElderlySafetyTab extends ConsumerWidget {
  const ElderlySafetyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicalProfileAsync = ref.watch(medicalProfileProvider);
    final contactsAsync = ref.watch(contactsProvider);

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
                colors: [Color(0xFF047857), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.elderly, size: 44, color: Colors.white),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'প্রবীণ ও স্বাস্থ্য সেবা মোড',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'বড় বাটনে সহজ স্পর্শে সাহায্য ও হঠাৎ পড়ে যাওয়া শনাক্তকরণ',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Big Elderly SOS Button
          BigSosButton(
            buttonColor: AppColors.elderlySafetyAccent,
            label: 'জরুরি সাহায্য',
            size: 200,
            onTap: () {
              ref.read(sosEngineProvider.notifier).trigger(
                mode: SafetyMode.elderly,
                reason: 'প্রবীণ মোড ১-ট্যাপ ইমার্জেন্সি',
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActiveSosScreen()),
              );
            },
          ),
          const SizedBox(height: 28),

          // 1-Tap Direct Call to Primary Guardian
          contactsAsync.when(
            data: (contacts) {
              final primary = contacts.isNotEmpty
                  ? contacts.firstWhere((c) => c.isPrimary, orElse: () => contacts.first)
                  : null;
              if (primary == null) return const SizedBox.shrink();

              return Card(
                color: const Color(0xFFE6FFFA),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.elderlySafetyAccent,
                    child: Icon(Icons.phone_in_talk, color: Colors.white),
                  ),
                  title: Text(
                    'সন্তান/অভিভাবককে কল (${primary.name})',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                  subtitle: Text(primary.phoneNumber, style: const TextStyle(color: Color(0xFF047857))),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.elderlySafetyAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => SmsDispatcher.dialNumber(primary.phoneNumber),
                    child: const Text('কল করুন'),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),

          // Medical ID Quick Card
          medicalProfileAsync.when(
            data: (profile) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'জরুরি মেডিকেল প্রোফাইল',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MedicalIdScreen()),
                              );
                            },
                            child: const Text('সম্পাদনা'),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'ব্লাড গ্রুপ: ${profile.bloodGroup}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'এলার্জি: ${profile.allergies.isEmpty ? "নেই" : profile.allergies}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
