import 'package:camera_control/camera_control.dart';
import 'package:test/test.dart';

/// A fake backend for registry tests.
class _FakeBackend implements CameraBackend {
  _FakeBackend(this.name, this.priority, {this.isAvailable = true});

  @override
  final String name;

  @override
  final int priority;

  @override
  final bool isAvailable;

  @override
  Future<void> dispose() async {}

  @override
  Future<List<CameraDevice>> enumerate() async => const [];

  @override
  Future<Camera> open(CameraDevice device) async =>
      throw const DeviceException('fake');
}

void main() {
  group('CameraBackendRegistry', () {
    setUp(CameraBackendRegistry.instance.reset);

    test('selects the highest-priority available backend', () {
      CameraBackendRegistry.instance.register(_FakeBackend('low', 1));
      CameraBackendRegistry.instance.register(_FakeBackend('high', 100));
      expect(CameraBackendRegistry.instance.selected.name, 'high');
    });

    test('skips unavailable backends', () {
      CameraBackendRegistry.instance
          .register(_FakeBackend('off', 100, isAvailable: false));
      CameraBackendRegistry.instance.register(_FakeBackend('on', 1));
      expect(CameraBackendRegistry.instance.selected.name, 'on');
    });

    test('throws when nothing is available', () {
      CameraBackendRegistry.instance
          .register(_FakeBackend('off', 1, isAvailable: false));
      expect(() => CameraBackendRegistry.instance.selected, throwsStateError);
    });

    test('caches selection until a new register', () {
      CameraBackendRegistry.instance.register(_FakeBackend('a', 1));
      expect(CameraBackendRegistry.instance.selected.name, 'a');
      CameraBackendRegistry.instance.register(_FakeBackend('b', 100));
      expect(CameraBackendRegistry.instance.selected.name, 'b');
    });
  });

  group('CameraFormat', () {
    test('toString reports resolution, format, and fps', () {
      const fmt = CameraFormat(
        width: 1280,
        height: 720,
        pixelFormat: PixelFormat.bgra8888,
        frameRate: 30,
      );
      expect(fmt.toString(), '1280x720 bgra8888 @30fps');
    });
  });

  group('models', () {
    test('CameraDevice defaults to external facing and no formats', () {
      const d = CameraDevice(id: 'cam0', name: 'Test Cam');
      expect(d.facing, CameraFacing.external);
      expect(d.formats, isEmpty);
    });
  });
}
