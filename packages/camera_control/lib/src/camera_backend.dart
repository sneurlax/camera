import 'camera.dart';
import 'camera_device.dart';

/// Contract every camera backend implements.
///
/// A backend provides camera access via some platform technique. Backends are
/// registered with [CameraBackendRegistry] and chosen by availability and
/// priority, so different platforms (or different techniques on the same
/// platform) can supply their own.
abstract class CameraBackend {
  /// Short, stable identifier (e.g. `ffi`, `web`, `stub`).
  String get name;

  /// Whether this backend can run in the current process/platform.
  bool get isAvailable;

  /// Higher wins when multiple backends are available.
  int get priority;

  /// List the cameras this backend can see.
  Future<List<CameraDevice>> enumerate();

  /// Open [device] for capture.
  Future<Camera> open(CameraDevice device);

  /// Release any resources held by the backend.
  Future<void> dispose();
}

/// Registry of available [CameraBackend]s.
///
/// The registry keeps an ordered list and returns the highest-priority
/// available backend. Consumers can register their own before first use to
/// override the defaults.
class CameraBackendRegistry {
  CameraBackendRegistry._();

  /// The process-wide registry.
  static final CameraBackendRegistry instance = CameraBackendRegistry._();

  final List<CameraBackend> _backends = [];
  CameraBackend? _selected;

  /// Register a backend. Last registered of equal priority wins ties.
  void register(CameraBackend backend) {
    _backends.add(backend);
    _selected = null;
  }

  /// All registered backends, for inspection/testing.
  List<CameraBackend> get backends => List.unmodifiable(_backends);

  /// The chosen backend: highest priority among available ones.
  CameraBackend get selected {
    final cached = _selected;
    if (cached != null) return cached;
    final available = _backends.where((b) => b.isAvailable).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    if (available.isEmpty) {
      throw StateError('No available camera backend registered');
    }
    final chosen = available.first;
    _selected = chosen;
    return chosen;
  }

  /// Reset registry (tests).
  void reset() {
    _backends.clear();
    _selected = null;
  }
}
