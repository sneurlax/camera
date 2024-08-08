#include "include/camera/camera_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "camera_plugin.h"

void CameraPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  camera::CameraPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
