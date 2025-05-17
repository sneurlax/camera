import 'package:camera_control_flutter/camera_control_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('camera_control_flutter re-exports the camera_control API', () {
    // Smoke test: the plugin re-exports the pure-Dart API.
    expect(CameraControl.enumerate, isNotNull);
    expect(CameraControl.open, isNotNull);
  });
}
