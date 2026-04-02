
import 'package:flutter/material.dart';

class ToggleChip extends StatelessWidget {
  final bool selected;
  final String text;

  const ToggleChip({super.key, required this.selected, required this.text});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: selected ? 0.28 : 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 0.95 : 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          
        ),
   
      ),
    );

  }
}