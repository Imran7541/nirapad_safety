import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/safety_mode.dart';
import '../../../domain/services/shake_detector_service.dart';
import '../../providers/app_providers.dart';
import '../contacts/trusted_contacts_screen.dart';
import '../community/nearby_responders_screen.dart';
import '../medical/medical_id_screen.dart';
import '../ai/safety_ai_agent_screen.dart';
import '../modes/biker_safety_tab.dart';
import '../modes/elderly_safety_tab.dart';
import '../modes/women_safety_tab.dart';
import '../settings/settings_screen.dart';
import '../sos/active_sos_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  ShakeDetectorService? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _initShakeDetector();
  }

  void _initShakeDetector() {
    final prefs = ref.read(prefsManagerProvider);
    if (prefs.isShakeTriggerEnabled) {
      _shakeDetector = ShakeDetectorService(
        onShake: () {
          final mode = ref.read(safetyModeProvider);
          ref.read(sosEngineProvider.notifier).trigger(
            mode: mode,
            reason: 'ঝাঁকুনি (Shake) দ্বারা স্বয়ংক্রিয় এসওএস',
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ActiveSosScreen()),
          );
        },
      );
      _shakeDetector?.startListening();
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(safetyModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'নিরাপদ (Nirapad)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'অফলাইন-ফার্স্ট লাইফ শিল্ড',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // National Helpline 999 Direct Call Action
          IconButton(
            tooltip: '৯৯৯ জাতীয় জরুরি সেবা',
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.emergencyRed,
              child: Text('999', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            onPressed: () {
              ref.read(sosEngineProvider.notifier).trigger(
                mode: currentMode,
                reason: 'টপবার ৯৯৯ ইমার্জেন্সি',
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActiveSosScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBodyForNavIndex(_navIndex, currentMode),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (idx) => setState(() => _navIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'অভিভাবক',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_information_outlined),
            selectedIcon: Icon(Icons.medical_information),
            label: 'মেডিকেল আইডি',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'রক্তদাতা ও হেল্পার',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'এআই গাইড',
          ),
        ],
      ),
    );
  }

  Widget _buildBodyForNavIndex(int index, SafetyMode currentMode) {
    switch (index) {
      case 0:
        return Column(
          children: [
            // Mode Selector Segmented Control
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildModeChip(
                      mode: SafetyMode.women,
                      label: '👩 নারী ও শিক্ষার্থী',
                      isSelected: currentMode == SafetyMode.women,
                      accentColor: AppColors.womenSafetyAccent,
                    ),
                    const SizedBox(width: 8),
                    _buildModeChip(
                      mode: SafetyMode.biker,
                      label: '🏍️ বাইকার ও হাইওয়ে',
                      isSelected: currentMode == SafetyMode.biker,
                      accentColor: AppColors.bikerSafetyAccent,
                    ),
                    const SizedBox(width: 8),
                    _buildModeChip(
                      mode: SafetyMode.elderly,
                      label: '👴 প্রবীণ ও মেডিকেল',
                      isSelected: currentMode == SafetyMode.elderly,
                      accentColor: AppColors.elderlySafetyAccent,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Active Mode Body
            Expanded(child: _buildActiveModeView(currentMode)),
          ],
        );
      case 1:
        return const TrustedContactsScreen();
      case 2:
        return const MedicalIdScreen();
      case 3:
        return const NearbyRespondersScreen();
      case 4:
        return const SafetyAiAgentScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildModeChip({
    required SafetyMode mode,
    required String label,
    required bool isSelected,
    required Color accentColor,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selected: isSelected,
      selectedColor: accentColor,
      onSelected: (selected) {
        if (selected) {
          ref.read(safetyModeProvider.notifier).setMode(mode);
        }
      },
    );
  }

  Widget _buildActiveModeView(SafetyMode mode) {
    switch (mode) {
      case SafetyMode.women:
        return const WomenSafetyTab();
      case SafetyMode.biker:
        return const BikerSafetyTab();
      case SafetyMode.elderly:
        return const ElderlySafetyTab();
    }
  }
}
