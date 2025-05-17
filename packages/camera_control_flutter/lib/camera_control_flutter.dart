/// Flutter integration for the `camera_control` package.
///
/// This package contributes the native `camera_control` library to your Flutter
/// app (built automatically via cargokit) and re-exports the full
/// `camera_control` API. In most cases you only need the re-exported
/// [CameraControl] entry point:
///
/// ```dart
/// import 'package:camera_control_flutter/camera_control_flutter.dart';
///
/// await CameraControlFlutter.ensureInitialized();
/// final cameras = await CameraControl.enumerate();
/// ```
library;

import 'package:camera_control/camera_control.dart';

export 'package:camera_control/camera_control.dart';

/// Flutter-side conveniences over the `camera_control` registry.
abstract final class CameraControlFlutter {
  /// Ensures a camera backend is selected and ready.
  ///
  /// On native platforms `camera_control` auto-registers the FFI backend that
  /// loads the bundled native library; this initializes it eagerly so the first
  /// call has no setup latency. Returns the name of the active backend (e.g.
  /// `ffi`, or `stub` when no camera is available).
  static Future<String> ensureInitialized() async {
    CameraControl.ensureInitialized();
    return CameraBackendRegistry.instance.selected.name;
  }
}
