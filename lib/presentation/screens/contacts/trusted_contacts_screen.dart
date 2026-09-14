import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/sms_dispatcher.dart';
import '../../../data/models/contact_model.dart';
import '../../providers/app_providers.dart';

class TrustedContactsScreen extends ConsumerWidget {
  const TrustedContactsScreen({super.key});

  void _showAddContactDialog(BuildContext context, WidgetRef ref, [ContactModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber ?? '');
    final relationCtrl = TextEditingController(text: existing?.relation ?? 'প্যারেন্ট');
    bool isPrimary = existing?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'বিশ্বস্ত কন্টাক্ট যোগ করুন' : 'কন্টাক্ট সম্পাদনা'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'নাম (যেমন: বাবা/মা/ভাই)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'মোবাইল নম্বর (০১XXXXXXXXX)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: relationCtrl,
                      decoration: const InputDecoration(labelText: 'সম্পর্ক'),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('প্রধান অভিভাবক (Primary) হিসেবে সেট করুন'),
                      value: isPrimary,
                      onChanged: (val) {
                        setDialogState(() => isPrimary = val ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('বাতিল'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();
                    if (name.isEmpty || phone.isEmpty) return;

                    final contact = ContactModel(
                      id: existing?.id ?? const Uuid().v4(),
                      name: name,
                      phoneNumber: phone,
                      relation: relationCtrl.text.trim(),
                      isPrimary: isPrimary,
                    );

                    if (existing == null) {
                      ref.read(contactsProvider.notifier).addContact(contact);
                    } else {
                      ref.read(contactsProvider.notifier).updateContact(contact);
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('সংরক্ষণ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('বিশ্বস্ত অভিভাবক ও কন্টাক্ট'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.emergencyRed,
        foregroundColor: Colors.white,
        onPressed: () => _showAddContactDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('নতুন নম্বর যোগ করুন'),
      ),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return const Center(
              child: Text('কোনো কন্টাক্ট যুক্ত করা নেই। নিচে থেকে যোগ করুন।'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: contact.isPrimary ? AppColors.emergencyRed : Colors.grey.shade700,
                    child: Icon(
                      contact.isPrimary ? Icons.star : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (contact.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('${contact.phoneNumber} (${contact.relation})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => SmsDispatcher.dialNumber(contact.phoneNumber),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _showAddContactDialog(context, ref, contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => ref.read(contactsProvider.notifier).deleteContact(contact.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('ত্রুটি: $err')),
      ),
    );
  }
}
