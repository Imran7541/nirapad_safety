import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BigSosButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color buttonColor;
  final String label;
  final double size;

  const BigSosButton({
    super.key,
    required this.onTap,
    this.buttonColor = AppColors.emergencyRed,
    this.label = 'SOS',
    this.size = 180,
  });

  @override
  State<BigSosButton> createState() => _BigSosButtonState();
}

class _BigSosButtonState extends State<BigSosButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Center(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.buttonColor,
                  boxShadow: [
                    BoxShadow(
                      color: widget.buttonColor.withValues(alpha: 0.4),
                      blurRadius: 28,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: widget.buttonColor.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'জরুরি সাহায্য',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
