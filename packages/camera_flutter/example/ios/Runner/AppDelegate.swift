import Flutter
import UIKit

// Implemented in the camera_cli Rust crate, force-loaded into the plugin
// framework. Stops every capture session synchronously so the capture thread
// cannot invoke a deleted Dart callback while the engine is shutting down.
@_silgen_name("camera_cli_close_all")
func camera_cli_close_all()

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    camera_cli_close_all()
    super.applicationWillTerminate(application)
  }
}
