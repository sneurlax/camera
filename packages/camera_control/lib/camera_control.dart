/// Cross-platform camera access for Dart and Flutter.
///
/// Pure Dart: no Flutter dependency, so this package works in CLI tools as well
/// as Flutter apps. Native capture is reached over `dart:ffi`; on the web
/// getUserMedia is used instead.
library;

export 'src/camera_control.dart';
export 'src/camera.dart';
export 'src/camera_device.dart';
export 'src/camera_format.dart';
export 'src/frame.dart';
export 'src/exceptions.dart';
export 'src/camera_backend.dart' show CameraBackend, CameraBackendRegistry;
