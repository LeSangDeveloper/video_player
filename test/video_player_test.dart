import 'dart:typed_data';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/models/data_source.dart';
import 'package:video_player/models/video_event.dart';
import 'package:video_player/video_player_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVideoPlayerPlatform
    with MockPlatformInterfaceMixin
    implements VideoPlayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Widget buildView(int textureId) {
    // TODO: implement buildView
    throw UnimplementedError();
  }

  @override
  Future<int?> create(DataSource dataSource) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> dispose(int textureId) {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> getFrame(int textureId, Duration position) {
    // TODO: implement getFrame
    throw UnimplementedError();
  }

  @override
  Future<Duration> getPosition(int textureId) {
    // TODO: implement getPosition
    throw UnimplementedError();
  }

  @override
  Future<void> pause(int textureId) {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> play(int textureId) {
    // TODO: implement play
    throw UnimplementedError();
  }

  @override
  Future<void> seekTo(int textureId, Duration position) {
    // TODO: implement seekTo
    throw UnimplementedError();
  }

  @override
  Future<void> setLooping(int textureId, bool looping) {
    // TODO: implement setLooping
    throw UnimplementedError();
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    // TODO: implement setMixWithOthers
    throw UnimplementedError();
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    // TODO: implement setPlaybackSpeed
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(int textureId, double volume) {
    // TODO: implement setVolume
    throw UnimplementedError();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    // TODO: implement videoEventsFor
    throw UnimplementedError();
  }

}

void main() {
  final VideoPlayerPlatform initialPlatform = VideoPlayerPlatform.instance;

  test('getPlatformVersion', () async {

  });
}
