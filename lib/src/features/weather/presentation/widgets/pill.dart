
import 'package:flutter/material.dart';
import 'glass_card.dart';

class Pill extends StatelessWidget {
  final String text;

  const Pill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurSigma: 10,
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}