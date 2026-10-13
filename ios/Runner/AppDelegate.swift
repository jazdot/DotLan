import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.jazdot.dotlan/discovery"
  private var iosEngine: DotLanIosEngine?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

    if #available(iOS 13.0, *) {
      iosEngine = DotLanIosEngine()
    }

    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "startBonjourScan":
        if #available(iOS 13.0, *) {
          self?.iosEngine?.startBonjourScan(onFound: { device in
            channel.invokeMethod("onBonjourDeviceFound", arguments: device)
          })
          result(true)
        } else {
          result(FlutterError(code: "UNSUPPORTED_OS", message: "iOS 13+ required", details: nil))
        }
      case "stopBonjourScan":
        if #available(iOS 13.0, *) {
          self?.iosEngine?.stopScan()
          result(true)
        } else {
          result(true)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
