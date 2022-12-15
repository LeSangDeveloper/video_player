import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:video_player/messages.g.dart';
import 'package:video_player/video_player_platform_interface.dart';

class PigeonVideoPlayer extends VideoPlayerPlatform {
  final VideoPlayerApi _api = VideoPlayerApi();

  @override
  Future<TextureMessage> create(CreateMessage arg_msg) async {
    return _api.create(arg_msg);
  }

  @override
  Future<void> dispose(TextureMessage arg_msg) async {
    return _api.dispose(arg_msg);
  }

  @override
  Future<void> setLooping(LoopingMessage arg_msg) async {
    return _api.setLooping(arg_msg);
  }

  @override
  Future<void> setVolume(VolumeMessage arg_msg) async {
    return _api.setVolume(arg_msg);
  }

  @override
  Future<void> setPlaybackSpeed(PlaybackSpeedMessage arg_msg) async {
    return _api.setPlaybackSpeed(arg_msg);
  }

  @override
  Future<void> play(TextureMessage arg_msg) async {
    return _api.pause(arg_msg);
  }

  @override
  Future<PositionMessage> position(TextureMessage arg_msg) async {
    return _api.position(arg_msg);
  }

  @override
  Future<Uint8List> getFrame(PositionMessage arg_msg) async {
    return _api.getFrame(arg_msg);
  }

  @override
  Future<void> seekTo(PositionMessage arg_msg) async {
    return _api.seekTo(arg_msg);
  }

  @override
  Future<void> pause(TextureMessage arg_msg) async {
    return _api.pause(arg_msg);
  }

  @override
  Future<void> setMixWithOthers(MixWithOthersMessage arg_msg) async {
    return _api.setMixWithOthers(arg_msg);
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

}