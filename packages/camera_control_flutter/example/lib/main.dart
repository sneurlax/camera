import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera_control_flutter/camera_control_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'camera_control example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _backend = '';
  List<CameraDevice> _devices = const [];
  String? _error;

  Camera? _camera;
  StreamSubscription<Frame>? _sub;
  ui.Image? _preview;
  bool _streaming = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final backend = await CameraControlFlutter.ensureInitialized();
      final devices = await CameraControl.enumerate();
      setState(() {
        _backend = backend;
        _devices = devices;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  Future<void> _start(CameraDevice device) async {
    await _stop();
    try {
      final camera = await CameraControl.open(device);
      _camera = camera;
      _streaming = true;
      _sub = camera.frames().listen(
        (frame) => unawaited(_onFrame(frame)),
        onError: (Object e) => setState(() => _error = '$e'),
      );
      setState(() {});
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  Future<void> _onFrame(Frame frame) async {
    // Decode raw pixels into an Image. The decoder reads RGBA, so swap channels
    // when the source is BGRA.
    final rgba = frame.pixelFormat == PixelFormat.bgra8888
        ? _bgraToRgba(frame.bytes)
        : frame.bytes;
    final buffer = await ui.ImmutableBuffer.fromUint8List(rgba);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: frame.width,
      height: frame.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final info = await codec.getNextFrame();
    buffer.dispose();
    descriptor.dispose();
    codec.dispose();
    if (!mounted || !_streaming) {
      info.image.dispose();
      return;
    }
    setState(() {
      _preview?.dispose();
      _preview = info.image;
    });
  }

  static Uint8List _bgraToRgba(Uint8List bgra) {
    final out = Uint8List(bgra.length);
    for (var i = 0; i + 3 < bgra.length; i += 4) {
      out[i] = bgra[i + 2];
      out[i + 1] = bgra[i + 1];
      out[i + 2] = bgra[i];
      out[i + 3] = bgra[i + 3];
    }
    return out;
  }

  Future<void> _stop() async {
    _streaming = false;
    await _sub?.cancel();
    _sub = null;
    await _camera?.close();
    _camera = null;
    _preview?.dispose();
    _preview = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('camera_control example'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Backend: $_backend'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _preview != null
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: RawImage(image: _preview),
                    ),
                  )
                : ListView(
                    children: [
                      for (final d in _devices)
                        ListTile(
                          title: Text(d.name),
                          subtitle: Text(
                            '${d.id}\n${d.formats.length} formats, '
                            '${d.facing.name}',
                          ),
                          isThreeLine: true,
                          onTap: () => _start(d),
                        ),
                      if (_devices.isEmpty)
                        const ListTile(
                          title: Text('No cameras found'),
                          subtitle: Text('Grant camera access, then refresh.'),
                        ),
                    ],
                  ),
          ),
          if (_camera != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: _stop,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ),
        ],
      ),
    );
  }
}
