import 'package:camera_flutter/camera_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('camera_flutter re-exports the camera_dart API', () {
    // Smoke test: the plugin re-exports the pure-Dart API.
    expect(CameraControl.enumerate, isNotNull);
    expect(CameraControl.open, isNotNull);
  });
}
