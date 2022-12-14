import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:video_player/messages.g.dart';
import 'package:video_player/models/data_source.dart';
import 'package:video_player/video_player_platform_interface.dart';

import 'enums/data_souce_type.dart';
import 'enums/video_event_type.dart';
import 'enums/video_format.dart';
import 'models/duration_range.dart';
import 'models/video_event.dart';

class PigeonVideoPlayer extends VideoPlayerPlatform {
  final VideoPlayerApi _api = VideoPlayerApi();

  static const Map<VideoFormat, String> _videoFormatStringMap =
  <VideoFormat, String>{
    VideoFormat.ss: 'ss',
    VideoFormat.hls: 'hls',
    VideoFormat.dash: 'dash',
    VideoFormat.other: 'other',
  };

  @override
  Future<int?> create(DataSource dataSource) async {
    String? asset;
    String? packageName;
    String? uri;
    String? formatHint;

    Map<String, String> httpHeaders = <String, String>{};
    switch (dataSource.getSourceType()) {
      case DataSourceType.asset:
        asset = dataSource.asset;
        packageName = dataSource.package;
        break;
      case DataSourceType.network:
        uri = dataSource.uri;
        formatHint = _videoFormatStringMap[dataSource.formatHint];
        httpHeaders = dataSource.httpHeaders;
        break;
      case DataSourceType.file:
        uri = dataSource.uri;
        break;
      case DataSourceType.contentUri:
        uri = dataSource.uri;
        break;
    }
    final CreateMessage message = CreateMessage(
      asset: asset,
      packageName: packageName,
      uri: uri,
      httpHeaders: httpHeaders,
      formatHint: formatHint,
    );

    final TextureMessage response = await _api.create(message);
    return response.textureId;
  }

  @override
  Future<void> dispose(int textureId) async {
    return _api.dispose(TextureMessage(textureId: textureId));
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    return _api.setLooping(LoopingMessage(
      textureId: textureId,
      isLooping: looping,
    ));
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    return _api.setVolume(VolumeMessage(
      textureId: textureId,
      volume: volume,
    ));
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    assert(speed > 0);

    return _api.setPlaybackSpeed(PlaybackSpeedMessage(
      textureId: textureId,
      speed: speed,
    ));
  }

  @override
  Future<void> play(int textureId) async {
    return _api.play(TextureMessage(textureId: textureId));
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    final PositionMessage response =
    await _api.position(TextureMessage(textureId: textureId));
    return Duration(milliseconds: response.position);
  }

  @override
  Future<Uint8List> getFrame(textureId, Duration position) async {
    return _api.getFrame(PositionMessage(
      textureId: textureId,
      position: position.inMilliseconds,
    ));
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    return _api.seekTo(PositionMessage(
      textureId: textureId,
      position: position.inMilliseconds,
    ));
  }

  @override
  Future<void> pause(int textureId) async {
    return _api.pause(TextureMessage(textureId: textureId));
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    return _api
        .setMixWithOthers(MixWithOthersMessage(mixWithOthers: mixWithOthers));
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$textureId');
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return _eventChannelFor(textureId)
        .receiveBroadcastStream()
        .map((dynamic event) {
      final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
      switch (map['event']) {
        case 'initialized':
          return VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration'] as int),
            size: Size((map['width'] as num?)?.toDouble() ?? 0.0,
                (map['height'] as num?)?.toDouble() ?? 0.0),
            rotationCorrection: map['rotationCorrection'] as int? ?? 0,
          );
        case 'completed':
          return VideoEvent(
            eventType: VideoEventType.completed,
          );
        case 'bufferingUpdate':
          final List<dynamic> values = map['values'] as List<dynamic>;

          return VideoEvent(
            buffered: values.map<DurationRange>(_toDurationRange).toList(),
            eventType: VideoEventType.bufferingUpdate,
          );
        case 'bufferingStart':
          return VideoEvent(eventType: VideoEventType.bufferingStart);
        case 'bufferingEnd':
          return VideoEvent(eventType: VideoEventType.bufferingEnd);
        default:
          return VideoEvent(eventType: VideoEventType.unknown);
      }
    });
  }

  DurationRange _toDurationRange(dynamic value) {
    final List<dynamic> pair = value as List<dynamic>;
    return DurationRange(
      Duration(milliseconds: pair[0] as int),
      Duration(milliseconds: pair[1] as int),
    );
  }

}