import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        // 注册运动传感器插件
        if let controller = window?.rootViewController as? FlutterViewController {
            MotionPlugin.register(with: registrar(forPlugin: "MotionPlugin")!)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
