import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_player/models/data_source.dart';
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

  Future<int?> create(DataSource dataSource) async {
    throw UnimplementedError('create() has not been implemented.');
  }

  Future<void> dispose(int textureId) async {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Future<void> setLooping(int textureId, bool looping) async {
    throw UnimplementedError('setLooping() has not been implemented.');
  }

  Future<void> setVolume(int textureId, double volume) async {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  Future<void> play(int textureId) async {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<Duration> getPosition(int textureId) async {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  Future<Uint8List> getFrame(int textureId, Duration position) async {
    throw UnimplementedError('getFrame() has not been implemented.');
  }

  Future<void> seekTo(int textureId, Duration position) async {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  Future<void> pause(int textureId) async {
    throw UnimplementedError('pause() has not been implemented.');
  }

  Future<void> setMixWithOthers(bool mixWithOthers) async {
    throw UnimplementedError('setMixWithOthers() has not been implemented.');;
  }

  /// Returns a widget displaying the video with a given textureID.
  Widget buildView(int textureId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

}
