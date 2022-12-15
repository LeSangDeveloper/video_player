import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_player/pigeon_video_player.dart';

import 'messages.g.dart';

abstract class VideoPlayerPlatform extends PlatformInterface {
  /// Constructs a VideoPlayerPlatform.
  VideoPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static PigeonVideoPlayer _instance = PigeonVideoPlayer();

  /// The default instance of [VideoPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoPlayer].
  static PigeonVideoPlayer get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoPlayerPlatform] when
  /// they register themselves.
  static set instance(PigeonVideoPlayer instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<TextureMessage> create(CreateMessage arg_msg) async {
    throw UnimplementedError('create() has not been implemented.');
  }

  Future<void> dispose(TextureMessage arg_msg) async {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Future<void> setLooping(LoopingMessage arg_msg) async {
    throw UnimplementedError('setLooping() has not been implemented.');
  }

  Future<void> setVolume(VolumeMessage arg_msg) async {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  Future<void> setPlaybackSpeed(PlaybackSpeedMessage arg_msg) async {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  Future<void> play(TextureMessage arg_msg) async {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<PositionMessage> position(TextureMessage arg_msg) async {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  Future<Uint8List> getFrame(PositionMessage arg_msg) async {
    throw UnimplementedError('getFrame() has not been implemented.');
  }

  Future<void> seekTo(PositionMessage arg_msg) async {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  Future<void> pause(TextureMessage arg_msg) async {
    throw UnimplementedError('pause() has not been implemented.');
  }

  Future<void> setMixWithOthers(MixWithOthersMessage arg_msg) async {
    throw UnimplementedError('setMixWithOthers() has not been implemented.');;
  }

  /// Returns a widget displaying the video with a given textureID.
  Widget buildView(int textureId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

}
