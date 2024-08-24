/// Exceptions thrown by the camera_control package.
library;

/// Base class for all camera errors.
class CameraException implements Exception {
  /// Human-readable message.
  final String message;

  /// Creates a camera exception with [message].
  const CameraException(this.message);

  @override
  String toString() => 'CameraException: $message';
}

/// Thrown when no backend can handle the request.
class NoBackendException extends CameraException {
  /// Creates a no-backend exception.
  const NoBackendException(super.message);
}

/// Thrown when a requested device cannot be found or opened.
class DeviceException extends CameraException {
  /// Creates a device exception.
  const DeviceException(super.message);
}

/// Thrown when capturing a frame fails.
class CaptureException extends CameraException {
  /// Creates a capture exception.
  const CaptureException(super.message);
}
