import 'dart:async';

import '../../camera.dart';
import '../../camera_backend.dart';
import '../../camera_device.dart';
import '../../exceptions.dart';

/// Web backend placeholder.
///
/// The web has no `dart:ffi`; camera access goes through getUserMedia and the
/// `mediaDevices` API. That implementation lands with the Web phase (see
/// ROADMAP). For now this reports no devices so the package compiles and runs
/// on web, with the stub backend taking over as the fallback.
CameraBackend? createNativeBackend() => _WebBackend();

class _WebBackend implements CameraBackend {
  @override
  String get name => 'web';

  @override
  bool get isAvailable => true;

  @override
  int get priority => 50;

  @override
  Future<void> dispose() async {}

  @override
  Future<List<CameraDevice>> enumerate() async => const [];

  @override
  Future<Camera> open(CameraDevice device) async {
    throw const DeviceException('Web camera backend not yet implemented');
  }
}
