import 'dart:typed_data';

import 'camera_format.dart';

/// One captured frame.
///
/// [bytes] holds the pixel data laid out per [pixelFormat] at [width]x[height].
/// For packed RGBA/BGRA the stride is `width * 4`; MJPEG frames are a complete
/// JPEG and ignore stride.
class Frame {
  /// Raw pixel (or encoded) bytes.
  final Uint8List bytes;

  /// Frame width in pixels.
  final int width;

  /// Frame height in pixels.
  final int height;

  /// Pixel layout of [bytes].
  final PixelFormat pixelFormat;

  /// Capture time, since some epoch the backend chooses (monotonic).
  final Duration timestamp;

  /// Creates a frame.
  const Frame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.pixelFormat,
    required this.timestamp,
  });

  @override
  String toString() =>
      'Frame(${width}x$height ${pixelFormat.name}, ${bytes.length} bytes)';
}
