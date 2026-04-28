import 'package:flutter/material.dart';
import '../models/state_payload.dart';
import '../services/state_service.dart';
import '../services/motion_service.dart';
import '../widgets/pet_widget.dart';
import '../widgets/fatigue_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _userId = 'usr_default';
  StatePayload? _state;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final state = await StateService().fetchFromServer(_userId);
    MotionService.startTracking(_userId);
    setState(() {
      _state = state;
      _loading = false;
    });
  }

  @override
  void dispose() {
    MotionService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final s = _state;
    if (s == null) {
      return const Scaffold(body: Center(child: Text('暂无数据，请先在 PC 端启动护眼精灵')));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Text('护眼精灵', style: TextStyle(fontSize: 18, letterSpacing: 4, color: Color(0xFF7DF9FF))),
              const SizedBox(height: 40),
              PetWidget(state: s),
              const SizedBox(height: 40),
              FatigueBar(label: '健康分', value: s.healthScore / 100, color: const Color(0xFF7DF9FF)),
              const SizedBox(height: 12),
              FatigueBar(label: '疲劳度', value: s.accumulatedFatigue / 60, color: const Color(0xFFFF6B6B)),
              const SizedBox(height: 24),
              _StatusChip(status: s.currentStatus),
              const Spacer(),
              Text('上次同步：${_formatTs(s.timestamp)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              TextButton(onPressed: _init, child: const Text('手动同步')),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTs(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final labels = {'active': '🟢 PC 活跃', 'idle': '🟡 PC 闲置', 'screen_locked': '🔒 PC 已锁屏'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7DF9FF22)),
      ),
      child: Text(labels[status] ?? status, style: const TextStyle(fontSize: 13)),
    );
  }
}
