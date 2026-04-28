import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/state_payload.dart';

const String _baseUrl = 'http://localhost:8080';
const String _localKey = 'cached_state';

class StateService {
  static final StateService _instance = StateService._();
  factory StateService() => _instance;
  StateService._();

  StatePayload? _current;
  StatePayload? get current => _current;

  /// 从服务端拉取最新状态（静默推送唤醒后调用）
  Future<StatePayload?> fetchFromServer(String userId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/state/$userId'));
      if (res.statusCode == 200) {
        final incoming = StatePayload.fromJson(jsonDecode(res.body));
        // LWW: 只接受比本地更新的状态
        if (_current == null || incoming.timestamp > _current!.timestamp) {
          _current = incoming;
          await _saveLocal(incoming);
        }
        return _current;
      }
    } catch (e) {
      // 网络异常，使用本地缓存
      return await _loadLocal();
    }
    return _current;
  }

  /// 上报运动状态（Core Motion / Activity Recognition 检测到步行后调用）
  Future<void> reportWalking(String userId, int restSeconds) async {
    if (_current == null) return;
    final updated = StatePayload(
      userId: userId,
      clientId: 'device_mobile',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      petLevel: _current!.petLevel,
      healthScore: (_current!.healthScore + restSeconds / 60 * 2).clamp(0, 100),
      accumulatedFatigue: (_current!.accumulatedFatigue - restSeconds ~/ 60).clamp(0, 999),
      currentStatus: 'active',
      lastBreakDuration: restSeconds,
    );
    await http.post(
      Uri.parse('$_baseUrl/api/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated.toJson()),
    );
    _current = updated;
    await _saveLocal(updated);
  }

  Future<void> _saveLocal(StatePayload state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(state.toJson()));
  }

  Future<StatePayload?> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return null;
    return StatePayload.fromJson(jsonDecode(raw));
  }
}
