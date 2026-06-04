import 'camera_format.dart';

/// Which way a camera points, when the platform reports it.
enum CameraFacing {
  /// Faces the user (selfie camera).
  front,

  /// Faces away from the user (rear camera).
  back,

  /// External or unknown orientation (most desktop webcams).
  external,
}

/// A camera the host exposes.
///
/// Descriptor only: holds no native resources. Open it with
/// [CameraControl.open] to capture frames.
class CameraDevice {
  /// Stable, platform-specific identifier.
  final String id;

  /// Human-readable name (e.g. "FaceTime HD Camera").
  final String name;

  /// Which way the camera points, if known.
  final CameraFacing facing;

  /// Capture formats the device advertises.
  final List<CameraFormat> formats;

  /// Creates a device descriptor.
  const CameraDevice({
    required this.id,
    required this.name,
    this.facing = CameraFacing.external,
    this.formats = const [],
  });

  @override
  String toString() => 'CameraDevice($id, $name, ${facing.name})';
}
