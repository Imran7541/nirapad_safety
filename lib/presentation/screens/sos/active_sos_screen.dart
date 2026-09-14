import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/sms_dispatcher.dart';
import '../../providers/app_providers.dart';
import '../../../domain/services/sos_engine.dart';

class ActiveSosScreen extends ConsumerStatefulWidget {
  const ActiveSosScreen({super.key});

  @override
  ConsumerState<ActiveSosScreen> createState() => _ActiveSosScreenState();
}

class _ActiveSosScreenState extends ConsumerState<ActiveSosScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _showPinInput = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleCancelWithPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পিন নম্বর প্রদান করুন')),
      );
      return;
    }

    final success = await ref.read(sosEngineProvider.notifier).cancelOrDuress(pin);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosEngineProvider);
    final engine = ref.watch(rawSosEngineProvider);
    final isCountdown = sosState == SOSState.countdown;
    final isDispatched = sosState == SOSState.dispatched || sosState == SOSState.duressDispatched;

    return PopScope(
      canPop: false, // Prevent accidental back button
      child: Scaffold(
        backgroundColor: AppColors.emergencyRedDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Blinking Emergency Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.crisis_alert,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  isCountdown ? 'এসওএস কাউন্টডাউন চলছে!' : 'জরুরি সংকেত প্রেরিত হয়েছে!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                if (isCountdown) ...[
                  Text(
                    '${engine.countdownRemaining}',
                    style: const TextStyle(
                      fontSize: 84,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'সেকেন্ডের মধ্যে স্বয়ংক্রিয়ভাবে অভিভাবক ও হেল্পলাইনে\nআপনার জিপিএস অবস্থান ও এসওএস চলে যাবে',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  // Immediate Send Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.emergencyRedDark,
                    ),
                    onPressed: () {
                      engine.triggerSOS(bypassCountdown: true);
                    },
                    icon: const Icon(Icons.flash_on),
                    label: const Text('কাউন্টডাউন ছাড়া এখনই পাঠান'),
                  ),
                ] else if (isDispatched) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'এসএমএস ও জিপিএস লিংক পাঠানো হয়েছে',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ঠিকানা: ${engine.currentIncident?.address ?? "যাচাই করা হচ্ছে..."}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // PIN Input or Cancel Buttons
                if (_showPinInput) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'নিরাপত্তা পিন প্রদান করুন (ক্যানসেল করতে)',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, color: Colors.white, letterSpacing: 8),
                          decoration: InputDecoration(
                            hintText: 'PIN',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => setState(() => _showPinInput = false),
                                child: const Text('পিছনে', style: TextStyle(color: Colors.white70)),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.emergencyRedDark,
                                ),
                                onPressed: _handleCancelWithPin,
                                child: const Text('নিশ্চিত করুন'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      // Direct 999 Call Button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            SmsDispatcher.dialNumber('999');
                          },
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: const Text('৯৯৯ কল', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Cancel Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black45,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setState(() {
                              _showPinInput = true;
                            });
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('ক্যানসেল (PIN)', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
