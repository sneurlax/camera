import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:camera/camera_platform_interface.dart';
import 'package:camera/camera_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCameraPlatform
    with MockPlatformInterfaceMixin
    implements CameraPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CameraPlatform initialPlatform = CameraPlatform.instance;

  test('$MethodChannelCamera is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCamera>());
  });

  test('getPlatformVersion', () async {
    Camera cameraPlugin = Camera();
    MockCameraPlatform fakePlatform = MockCameraPlatform();
    CameraPlatform.instance = fakePlatform;

    expect(await cameraPlugin.getPlatformVersion(), '42');
  });
}
