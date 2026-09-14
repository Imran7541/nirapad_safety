import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/medical_profile_model.dart';
import '../../providers/app_providers.dart';

class MedicalIdScreen extends ConsumerStatefulWidget {
  const MedicalIdScreen({super.key});

  @override
  ConsumerState<MedicalIdScreen> createState() => _MedicalIdScreenState();
}

class _MedicalIdScreenState extends ConsumerState<MedicalIdScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _chronicController;
  late TextEditingController _allergiesController;
  late TextEditingController _medsController;
  late TextEditingController _doctorPhoneController;
  late TextEditingController _hospitalController;

  String _selectedBloodGroup = 'B+';
  bool _isOrganDonor = false;
  bool _isInitialized = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _chronicController.dispose();
    _allergiesController.dispose();
    _medsController.dispose();
    _doctorPhoneController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  void _initFields(MedicalProfileModel profile) {
    if (_isInitialized) return;
    _nameController = TextEditingController(text: profile.fullName);
    _ageController = TextEditingController(text: profile.age > 0 ? profile.age.toString() : '');
    _chronicController = TextEditingController(text: profile.chronicConditions);
    _allergiesController = TextEditingController(text: profile.allergies);
    _medsController = TextEditingController(text: profile.regularMedications);
    _doctorPhoneController = TextEditingController(text: profile.emergencyDoctorPhone);
    _hospitalController = TextEditingController(text: profile.preferredHospital);
    _selectedBloodGroup = _bloodGroups.contains(profile.bloodGroup) ? profile.bloodGroup : 'B+';
    _isOrganDonor = profile.isOrganDonor;
    _isInitialized = true;
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = MedicalProfileModel(
        fullName: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        bloodGroup: _selectedBloodGroup,
        chronicConditions: _chronicController.text.trim(),
        allergies: _allergiesController.text.trim(),
        regularMedications: _medsController.text.trim(),
        emergencyDoctorPhone: _doctorPhoneController.text.trim(),
        preferredHospital: _hospitalController.text.trim(),
        isOrganDonor: _isOrganDonor,
      );

      await ref.read(medicalProfileProvider.notifier).updateProfile(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মেডিকেল প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(medicalProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('লক-স্ক্রিন মেডিকেল আইডি'),
      ),
      body: profileAsync.when(
        data: (profile) {
          _initFields(profile);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Blood Group Selection
                Card(
                  color: AppColors.emergencyRed.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'রক্তের গ্রুপ নির্বাচন করুন (Blood Group)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _bloodGroups.map((bg) {
                            final isSelected = bg == _selectedBloodGroup;
                            return ChoiceChip(
                              label: Text(
                                bg,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.emergencyRed,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedBloodGroup = bg);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'রোগী / ইউজারের পুরো নাম',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'বয়স (Age)',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(
                    labelText: 'গুরুতর এলার্জি (যেমন: পেনিসিলিন, ধুলোবালি)',
                    prefixIcon: Icon(Icons.warning_amber),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _chronicController,
                  decoration: const InputDecoration(
                    labelText: 'ক্রনিক রোগ (যেমন: অ্যাজমা, উচ্চ রক্তচাপ, ডায়াবেটিস)',
                    prefixIcon: Icon(Icons.favorite),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _medsController,
                  decoration: const InputDecoration(
                    labelText: 'প্রতিদিনের নিয়মিত ওষুধ (Regular Medications)',
                    prefixIcon: Icon(Icons.medication),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _doctorPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'পারিবারিক ডাক্তার বা ক্লিনিকের নম্বর',
                    prefixIcon: Icon(Icons.local_hospital),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _hospitalController,
                  decoration: const InputDecoration(
                    labelText: 'পছন্দনীয় নিকটস্থ হাসপাতাল',
                    prefixIcon: Icon(Icons.local_pharmacy),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('মেডিকেল প্রোফাইল সেভ করুন', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('ত্রুটি: $err')),
      ),
    );
  }
}
