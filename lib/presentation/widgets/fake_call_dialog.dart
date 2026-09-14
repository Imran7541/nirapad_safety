import 'dart:async';
import 'package:flutter/material.dart';

class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;

  const FakeCallScreen({
    super.key,
    this.callerName = 'আম্মু (Mother)',
    this.callerNumber = '+880 1711-XXXXXX',
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _isCallAnswered = false;
  int _callDurationSeconds = 0;
  Timer? _callTimer;

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _answerCall() {
    setState(() {
      _isCallAnswered = true;
    });
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDurationSeconds++;
      });
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatCallDuration(int sec) {
    final minutes = (sec ~/ 60).toString().padLeft(2, '0');
    final seconds = (sec % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Profile Avatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF374151),
              child: Icon(Icons.person, size: 60, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Text(
              widget.callerName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isCallAnswered
                  ? _formatCallDuration(_callDurationSeconds)
                  : 'ইনকামিং কল...',
              style: TextStyle(
                fontSize: 16,
                color: _isCallAnswered ? Colors.greenAccent : Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (!_isCallAnswered) ...[
              // Incoming Call Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'decline_call',
                          backgroundColor: Colors.red,
                          onPressed: _endCall,
                          child: const Icon(Icons.call_end, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text('কেটে দিন', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    // Accept
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'accept_call',
                          backgroundColor: Colors.green,
                          onPressed: _answerCall,
                          child: const Icon(Icons.call, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text('রিসিভ করুন', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // In-call Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: Center(
                  child: FloatingActionButton(
                    heroTag: 'end_active_call',
                    backgroundColor: Colors.red,
                    onPressed: _endCall,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
