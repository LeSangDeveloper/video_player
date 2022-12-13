#ifndef FLUTTER_PLUGIN_VIDEO_PLAYER_PLUGIN_H_
#define FLUTTER_PLUGIN_VIDEO_PLAYER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace video_player {

class VideoPlayerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  VideoPlayerPlugin();

  virtual ~VideoPlayerPlugin();

  // Disallow copy and assign.
  VideoPlayerPlugin(const VideoPlayerPlugin&) = delete;
  VideoPlayerPlugin& operator=(const VideoPlayerPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace video_player

#endif  // FLUTTER_PLUGIN_VIDEO_PLAYER_PLUGIN_H_
