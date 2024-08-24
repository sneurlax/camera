import 'dart:async';

import '../camera.dart';
import '../camera_device.dart';
import '../camera_backend.dart';
import '../exceptions.dart';

/// A backend that sees no cameras.
///
/// Always available; lowest priority. Lets code run (and tests pass) on hosts
/// with no camera support, and serves as the ultimate fallback.
class StubBackend implements CameraBackend {
  @override
  String get name => 'stub';

  @override
  bool get isAvailable => true;

  @override
  int get priority => -1000;

  @override
  Future<void> dispose() async {}

  @override
  Future<List<CameraDevice>> enumerate() async => const [];

  @override
  Future<Camera> open(CameraDevice device) async {
    throw const DeviceException('No camera backend available');
  }
}
