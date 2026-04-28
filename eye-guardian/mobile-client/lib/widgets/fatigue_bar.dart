import 'package:flutter/material.dart';

class FatigueBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 ~ 1.0
  final Color color;

  const FatigueBar({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8,
              backgroundColor: const Color(0xFF333333),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text('${(clamped * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
