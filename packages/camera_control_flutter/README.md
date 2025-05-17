# camera_control_flutter

Flutter integration for [`camera_control`](../camera_control): cross-platform
camera access with no system dependencies for your users.

This package contributes the native `camera_control` library to your Flutter app
(built automatically via [cargokit](git@github.com:ManyMath/cargokit)) and
re-exports the full `camera_control` API. In most cases you only need the
re-exported entry point:

```dart
import 'package:camera_control_flutter/camera_control_flutter.dart';

await CameraControlFlutter.ensureInitialized();
final cameras = await CameraControl.enumerate();
```

## Permissions

Camera access requires a usage description on Apple platforms
(`NSCameraUsageDescription` in your app's Info.plist) and the `CAMERA`
permission on Android. The example app sets these up.
