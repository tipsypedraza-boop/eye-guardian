import 'package:flutter/services.dart';
import 'state_service.dart';

/// 通过原生 MethodChannel 调用 iOS Core Motion / Android Activity Recognition
class MotionService {
  static const _channel = MethodChannel('eye_guardian/motion');
  static DateTime? _walkStartTime;

  static void startTracking(String userId) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWalking':
          _walkStartTime ??= DateTime.now();
          break;
        case 'onStationary':
          if (_walkStartTime != null) {
            final restSecs = DateTime.now().difference(_walkStartTime!).inSeconds;
            if (restSecs >= 60) {
              // 有效休息：步行超过 1 分钟，上报疲劳抵消
              await StateService().reportWalking(userId, restSecs);
            }
            _walkStartTime = null;
          }
          break;
      }
    });

    // 启动原生传感器监听
    _channel.invokeMethod('startActivityTracking');
  }

  static void stopTracking() {
    _channel.invokeMethod('stopActivityTracking');
  }
}
