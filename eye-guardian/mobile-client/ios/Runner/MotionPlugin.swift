import Flutter
import CoreMotion

class MotionPlugin: NSObject, FlutterPlugin {
    private let activityManager = CMMotionActivityManager()
    private var channel: FlutterMethodChannel?

    static func register(with registrar: FlutterPluginRegistrar) {
        let ch = FlutterMethodChannel(name: "eye_guardian/motion", binaryMessenger: registrar.messenger())
        let instance = MotionPlugin()
        instance.channel = ch
        registrar.addMethodCallDelegate(instance, channel: ch)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startActivityTracking":
            startTracking()
            result(nil)
        case "stopActivityTracking":
            activityManager.stopActivityUpdates()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startTracking() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            if activity.walking || activity.running {
                self?.channel?.invokeMethod("onWalking", arguments: nil)
            } else if activity.stationary {
                self?.channel?.invokeMethod("onStationary", arguments: nil)
            }
        }
    }
}
