import Cocoa
import FlutterMacOS

// Implemented in the camera_control Rust crate, force-loaded into the plugin
// framework. Stops every capture session synchronously so the capture thread
// cannot invoke a deleted Dart callback while the engine is shutting down.
@_silgen_name("camera_control_close_all")
func camera_control_close_all()

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationWillTerminate(_ notification: Notification) {
    // Runs on the main thread before the process (and Dart VM) is torn down.
    camera_control_close_all()
    super.applicationWillTerminate(notification)
  }
}
