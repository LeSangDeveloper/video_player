import 'dart:typed_data';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/messages.g.dart';
import 'package:video_player/video_player.dart';
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
  Future<TextureMessage> create(CreateMessage arg_msg) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> dispose(TextureMessage arg_msg) {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> getFrame(PositionMessage arg_msg) {
    // TODO: implement getFrame
    throw UnimplementedError();
  }

  @override
  Future<void> pause(TextureMessage arg_msg) {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> play(TextureMessage arg_msg) {
    // TODO: implement play
    throw UnimplementedError();
  }

  @override
  Future<PositionMessage> position(TextureMessage arg_msg) {
    // TODO: implement position
    throw UnimplementedError();
  }

  @override
  Future<void> seekTo(PositionMessage arg_msg) {
    // TODO: implement seekTo
    throw UnimplementedError();
  }

  @override
  Future<void> setLooping(LoopingMessage arg_msg) {
    // TODO: implement setLooping
    throw UnimplementedError();
  }

  @override
  Future<void> setMixWithOthers(MixWithOthersMessage arg_msg) {
    // TODO: implement setMixWithOthers
    throw UnimplementedError();
  }

  @override
  Future<void> setPlaybackSpeed(PlaybackSpeedMessage arg_msg) {
    // TODO: implement setPlaybackSpeed
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(VolumeMessage arg_msg) {
    // TODO: implement setVolume
    throw UnimplementedError();
  }
}

void main() {
  final VideoPlayerPlatform initialPlatform = VideoPlayerPlatform.instance;

  test('getPlatformVersion', () async {

  });
}
