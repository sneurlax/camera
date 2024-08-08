
import 'camera_platform_interface.dart';

class Camera {
  Future<String?> getPlatformVersion() {
    return CameraPlatform.instance.getPlatformVersion();
  }
}
