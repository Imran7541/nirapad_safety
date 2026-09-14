import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/sms_dispatcher.dart';

class NearbyRespondersScreen extends StatefulWidget {
  const NearbyRespondersScreen({super.key});

  @override
  State<NearbyRespondersScreen> createState() => _NearbyRespondersScreenState();
}

class _NearbyRespondersScreenState extends State<NearbyRespondersScreen> {
  String _selectedBloodFilter = 'All';

  final List<Map<String, dynamic>> _mockResponders = [
    {
      'name': 'তানভীর আহমেদ',
      'role': 'ভেরিফায়েড ভলান্টিয়ার (রেড ক্রিসেন্ট)',
      'distance': '৩৫০ মিটার',
      'bloodGroup': 'B+',
      'phone': '01711111111',
      'status': 'Active Now',
    },
    {
      'name': 'ড. সাদিয়া ইসলাম',
      'role': 'ফার্স্ট এইডার ও চিকিৎসক',
      'distance': '৬০০ মিটার',
      'bloodGroup': 'O+',
      'phone': '01822222222',
      'status': 'Active Now',
    },
    {
      'name': 'মেহেদী হাসান (বাইকার)',
      'role': 'কমিউনিটি রেসপন্ডার',
      'distance': '৮৫০ মিটার',
      'bloodGroup': 'A+',
      'phone': '01933333333',
      'status': 'Active Now',
    },
    {
      'name': 'রকিবুল ইসলাম',
      'role': 'নিয়মিত রক্তদাতা (B+)',
      'distance': '১.১ কিমি',
      'bloodGroup': 'B+',
      'phone': '01644444444',
      'status': 'Available',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedBloodFilter == 'All'
        ? _mockResponders
        : _mockResponders.where((r) => r['bloodGroup'] == _selectedBloodFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('নিকটস্থ ভলান্টিয়ার ও রক্তদাতা'),
      ),
      body: Column(
        children: [
          // Broadcast Help Button
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.emergencyRed.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.emergency_share, color: AppColors.emergencyRed, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'কমিউনিটি অ্যালার্ট ব্রডকাস্ট',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'ঘটনাস্থলের ১ কিমি ব্যাসার্ধের সকল ভলান্টিয়ারদের জরুরি সংকেত পাঠান',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🚨 নিকটস্থ সকল রেজিস্টার্ড ভলান্টিয়ারদের কাছে ব্রডকাস্ট পাঠানো হয়েছে!'),
                      ),
                    );
                  },
                  child: const Text('ব্রডকাস্ট'),
                ),
              ],
            ),
          ),

          // Blood Group Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((bg) {
                final isSelected = bg == _selectedBloodFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(bg == 'All' ? 'সব ডোনার' : bg),
                    selected: isSelected,
                    selectedColor: AppColors.emergencyRed,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedBloodFilter = bg);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Responders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        item['bloodGroup'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                    title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['role'] as String, style: const TextStyle(fontSize: 13)),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('দূরত্ব: ${item['distance']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () => SmsDispatcher.dialNumber(item['phone'] as String),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
