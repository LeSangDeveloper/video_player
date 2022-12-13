#include "include/video_player/video_player_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "video_player_plugin.h"

void VideoPlayerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  video_player::VideoPlayerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
