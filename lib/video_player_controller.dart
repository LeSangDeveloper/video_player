import 'package:flutter/cupertino.dart';
import 'package:video_player/enums/data_souce_type.dart';
import 'package:video_player/enums/video_format.dart';
import 'package:video_player/models/data_source.dart';

import 'models/VideoPlayerOptions.dart';
import 'models/video_player_value.dart';

class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {

  final String dataSource;
  final Map<String, String> httpHeaders;
  final VideoFormat? formatHint;
  final DataSourceType dataSourceType;
  final VideoPlayerOptions? videoPlayerOptions;
  final String? package;

  /// The id of a texture that hasn't been initialized.
  @visibleForTesting
  static const int kUninitializedTextureId = -1;
  int _textureId = kUninitializedTextureId;

  VideoPlayerController.network(
      this.dataSource, {
        this.formatHint,
        this.videoPlayerOptions,
        this.httpHeaders = const <String, String>{},
      }) : package = null, dataSourceType = DataSourceType.network, super(VideoPlayerValue(duration: Duration.zero));

  VideoPlayerController.file(
      this.dataSource, {
        this.formatHint,
        this.videoPlayerOptions,
        this.httpHeaders = const <String, String>{},
      }) : package = null, dataSourceType = DataSourceType.file, super(VideoPlayerValue(duration: Duration.zero));

  VideoPlayerController.asset(
      this.dataSource, {
        this.formatHint,
        this.videoPlayerOptions,
        this.httpHeaders = const <String, String>{},
      }) : package = null, dataSourceType = DataSourceType.asset, super(VideoPlayerValue(duration: Duration.zero));

  Future<void> initializeAsync() async {

  }

  Future<void> disposeAsync() async {

  }

  Future<void> playAsync() async {

  }

  Future<void> pauseAsync() async {

  }

  Future<void> seekToAsync(DataSource dataSource) async {

  }

  Future<void> setLoopingAsync(bool looping) async {

  }

  Future<void> setVolumeAsync(double volume) async {

  }

  Future<void> setPlaybackSpeedAsync(double speed) async {

  }

  int getTextureId() {
    return textureId;
  }

  @override
  void removeListener(VoidCallback listener) {

  }

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  @visibleForTesting
  int get textureId => _textureId;

}

class _VideoAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  bool _wasPlayingBeforePause = false;
  final VideoPlayerController _controller;

  _VideoAppLifeCycleObserver(this._controller);

  void initialize() {
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pauseAsync();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.playAsync();
        }
        break;
      default:
    }
  }

  void dispose() {
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
  }

}

T? _ambiguate<T>(T? value) => value;