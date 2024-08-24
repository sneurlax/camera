import 'camera.dart';
import 'camera_device.dart';
import 'camera_backend.dart';
import 'backends/native/native_backend.dart';
import 'backends/stub_backend.dart';

/// Entry point for camera access.
///
/// Static helpers cover the common cases; [CameraBackendRegistry] is there when
/// you need to choose or customize the backend.
class CameraControl {
  static bool _initialized = false;

  /// Registers the built-in backends once.
  ///
  /// Called automatically by the static helpers. Safe to call repeatedly.
  static void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    // Native (FFI) backend is default off-web; web backend swapped in by the
    // conditional import. Stub backend is the always-available fallback.
    final native = createNativeBackend();
    if (native != null) CameraBackendRegistry.instance.register(native);
    CameraBackendRegistry.instance.register(StubBackend());
  }

  /// List the cameras the host exposes.
  static Future<List<CameraDevice>> enumerate() async {
    ensureInitialized();
    return CameraBackendRegistry.instance.selected.enumerate();
  }

  /// Open [device] for capture.
  static Future<Camera> open(CameraDevice device) async {
    ensureInitialized();
    return CameraBackendRegistry.instance.selected.open(device);
  }

  /// Release every backend's resources, stopping any open cameras.
  ///
  /// Call this on app shutdown: it stops native capture synchronously so a
  /// background capture thread cannot deliver a frame into a torn-down isolate.
  static Future<void> dispose() async {
    for (final backend in CameraBackendRegistry.instance.backends) {
      await backend.dispose();
    }
  }
}
