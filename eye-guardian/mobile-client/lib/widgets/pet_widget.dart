import 'package:flutter/material.dart';
import '../models/state_payload.dart';

class PetWidget extends StatelessWidget {
  final StatePayload state;
  const PetWidget({super.key, required this.state});

  String get _emoji {
    if (state.healthScore >= 80) return '🌟';
    if (state.healthScore >= 50) return '😊';
    if (state.healthScore >= 20) return '😴';
    return '💀';
  }

  @override
  Widget build(BuildContext context) {
    final glowRadius = state.healthScore * 0.6;
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: const Color(0xFF7DF9FF).withOpacity(state.healthScore / 100), blurRadius: glowRadius, spreadRadius: 4)],
          ),
          child: Center(child: Text(_emoji, style: TextStyle(fontSize: 64 + state.petLevel * 2.0))),
        ),
        const SizedBox(height: 8),
        Text('Lv.${state.petLevel}', style: const TextStyle(color: Color(0xFF7DF9FF), letterSpacing: 2)),
      ],
    );
  }
}
