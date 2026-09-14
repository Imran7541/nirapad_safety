import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'domain/services/siren_alarm_service.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications and Alarm Service
  try {
    await SirenAlarmService.instance.init();
  } catch (e) {
    debugPrint('Siren Alarm Service init error: $e');
  }

  // Pre-load SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NirapadApp(),
    ),
  );
}

class NirapadApp extends StatelessWidget {
  const NirapadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'নিরাপদ - Nirapad Safety',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
