/// Pixel layout of captured frame bytes.
///
/// The native crate normalizes capture output to one of these so callers do not
/// have to handle every platform's native fourcc. `bgra8888` is the common
/// macOS/AVFoundation default; `rgba8888` is the canonical interchange format.
enum PixelFormat {
  /// 8 bits per channel, byte order R,G,B,A.
  rgba8888,

  /// 8 bits per channel, byte order B,G,R,A.
  bgra8888,

  /// Packed YUV 4:2:2 (one platform may hand this through unconverted).
  yuyv422,

  /// Motion JPEG: each frame is a complete JPEG.
  mjpeg,
}

/// A capture format a device supports: resolution, pixel format, frame rate.
///
/// Returned by [CameraDevice.formats]; pass one to open or configure a camera.
class CameraFormat {
  /// Frame width in pixels.
  final int width;

  /// Frame height in pixels.
  final int height;

  /// Pixel layout of frame bytes.
  final PixelFormat pixelFormat;

  /// Maximum frames per second at this resolution/format.
  final double frameRate;

  /// Creates a format descriptor.
  const CameraFormat({
    required this.width,
    required this.height,
    required this.pixelFormat,
    required this.frameRate,
  });

  @override
  String toString() =>
      '${width}x$height ${pixelFormat.name} @${frameRate.toStringAsFixed(0)}fps';
}
