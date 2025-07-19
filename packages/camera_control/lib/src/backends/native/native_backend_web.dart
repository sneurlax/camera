import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../camera.dart';
import '../../camera_backend.dart';
import '../../camera_device.dart';
import '../../camera_format.dart';
import '../../exceptions.dart';
import '../../frame.dart';

/// Web camera backend using getUserMedia and the mediaDevices API.
///
/// There is no `dart:ffi` on the web; camera access goes through the browser.
/// getUserMedia triggers the permission prompt and unlocks device labels, so
/// [enumerate] requests access first, then lists devices. Frames are pulled by
/// drawing the video element to an offscreen canvas and reading back RGBA
/// pixels per decoded frame.
CameraBackend? createNativeBackend() => WebBackend();

/// Camera backend backed by the browser mediaDevices API.
class WebBackend implements CameraBackend {
  @override
  String get name => 'web';

  @override
  bool get isAvailable => true;

  @override
  int get priority => 50;

  @override
  Future<void> dispose() async {}

  @override
  Future<List<CameraDevice>> enumerate() async {
    final devices = web.window.navigator.mediaDevices;

    // Requesting a stream prompts for permission and unlocks device labels.
    // Stop it immediately: we only needed the grant.
    try {
      final probe = await devices
          .getUserMedia(web.MediaStreamConstraints(video: true.toJS))
          .toDart;
      for (final track in probe.getTracks().toDart) {
        track.stop();
      }
    } catch (e) {
      throw DeviceException('Camera access denied or unavailable: $e');
    }

    final list = await devices.enumerateDevices().toDart;
    final out = <CameraDevice>[];
    for (final info in list.toDart) {
      if (info.kind != 'videoinput') continue;
      out.add(
        CameraDevice(
          id: info.deviceId,
          name: info.label.isEmpty ? 'Camera ${out.length + 1}' : info.label,
          // The browser does not surface facing for desktop webcams.
          facing: CameraFacing.external,
        ),
      );
    }
    return out;
  }

  @override
  Future<Camera> open(CameraDevice device) async {
    final devices = web.window.navigator.mediaDevices;
    // Request the chosen device by id. The video constraints are a JS object;
    // package:web's MediaTrackConstraints is a JSObject, passed as the JSAny
    // `video` value.
    final video = web.MediaTrackConstraints(deviceId: device.id.toJS);
    final constraints = web.MediaStreamConstraints(video: video as JSAny);
    final web.MediaStream stream;
    try {
      stream = await devices.getUserMedia(constraints).toDart;
    } catch (e) {
      throw DeviceException('Failed to open camera: $e');
    }
    final camera = _WebCamera(device, stream);
    await camera._start();
    return camera;
  }
}

class _WebCamera implements Camera {
  _WebCamera(this.device, this._stream)
    : _video = web.HTMLVideoElement(),
      _canvas = web.HTMLCanvasElement();

  final web.MediaStream _stream;
  final web.HTMLVideoElement _video;
  final web.HTMLCanvasElement _canvas;
  web.CanvasRenderingContext2D? _ctx;

  bool _closed = false;
  StreamController<Frame>? _controller;

  @override
  final CameraDevice device;

  @override
  CameraFormat get format => CameraFormat(
    width: _video.videoWidth,
    height: _video.videoHeight,
    pixelFormat: PixelFormat.rgba8888,
    frameRate: 0,
  );

  Future<void> _start() async {
    _video
      ..autoplay = true
      ..muted = true
      ..srcObject = _stream;
    await _video.play().toDart;
    _ctx = _canvas.getContext('2d') as web.CanvasRenderingContext2D?;
  }

  @override
  Future<Frame> captureFrame() => frames().first;

  @override
  Stream<Frame> frames() {
    if (_closed) throw const CaptureException('Camera is closed');
    final existing = _controller;
    if (existing != null) return existing.stream;

    final controller = StreamController<Frame>(onCancel: close);
    _controller = controller;
    _scheduleFrame();
    return controller.stream;
  }

  void _scheduleFrame() {
    // requestVideoFrameCallback fires once per decoded frame (supported by
    // Chrome, Brave, and Safari 16+); the callback gets (now, metadata).
    _video.requestVideoFrameCallback(
      ((JSNumber _, JSObject __) => _tick()).toJS,
    );
  }

  void _tick() {
    final controller = _controller;
    if (_closed || controller == null || controller.isClosed) return;
    final w = _video.videoWidth;
    final h = _video.videoHeight;
    final ctx = _ctx;
    if (ctx != null && w > 0 && h > 0) {
      _canvas
        ..width = w
        ..height = h;
      ctx.drawImage(_video, 0, 0);
      final image = ctx.getImageData(0, 0, w, h);
      controller.add(
        Frame(
          // toDart yields a Uint8ClampedList aliasing the ImageData buffer;
          // copy so the frame stays valid past the next tick.
          bytes: Uint8List.fromList(image.data.toDart),
          width: w,
          height: h,
          pixelFormat: PixelFormat.rgba8888,
          timestamp: Duration.zero,
        ),
      );
    }
    _scheduleFrame();
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final track in _stream.getTracks().toDart) {
      track.stop();
    }
    _video.srcObject = null;
    final controller = _controller;
    _controller = null;
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }
}
