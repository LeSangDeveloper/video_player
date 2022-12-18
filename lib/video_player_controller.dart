import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:video_player/enums/data_souce_type.dart';
import 'package:video_player/enums/video_format.dart';
import 'package:video_player/models/data_source.dart';
import 'package:video_player/models/video_event.dart';
import 'package:video_player/video_player_platform_interface.dart';

import 'enums/video_event_type.dart';
import 'models/VideoPlayerOptions.dart';
import 'models/video_player_value.dart';

class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {

  final String dataSource;
  final Map<String, String> httpHeaders;
  final VideoFormat? formatHint;
  final DataSourceType dataSourceType;
  final VideoPlayerOptions? videoPlayerOptions;
  final String? package;

  _VideoAppLifeCycleObserver? _lifeCycleObserver;
  int _textureId = kUninitializedTextureId;
  bool _isDisposed = false;
  Timer? _timer;
  StreamSubscription<dynamic>? _eventSubscription;
  Completer<void>? _creatingCompleter;

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  @visibleForTesting
  int get textureId => _textureId;
  bool get _isDisposedOrNotInitialized => _isDisposed || !value.isInitialized;
  Future<Duration?> get position async {
    if (_isDisposed) {
      return null;
    }
    return VideoPlayerPlatform.instance.getPosition(_textureId);
  }
  int getTextureId() {
    return textureId;
  }

  /// The id of a texture that hasn't been initialized.
  @visibleForTesting
  static const int kUninitializedTextureId = -1;

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
    final bool allowBackgroundPlayback = videoPlayerOptions?.allowBackgroundPlayback ?? false;
    _lifeCycleObserver?.initialize();
    _creatingCompleter = Completer<void>();
    Completer<void> initializingCompleter = Completer<void>();
    late DataSource dataSourceDescription = DataSource(
      sourceType: DataSourceType.asset,
      asset: dataSource,
      package: package,
    );

    if (!allowBackgroundPlayback) {
      _lifeCycleObserver = _VideoAppLifeCycleObserver(this);
    }
    _lifeCycleObserver?.initialize();
    await VideoPlayerPlatform.instance.setMixWithOthers(videoPlayerOptions!.mixWithOthers);
    _textureId = (await VideoPlayerPlatform.instance.create(dataSourceDescription)) ?? kUninitializedTextureId;
    _creatingCompleter?.complete(null);

    void eventListener(VideoEvent event) {
      if (_isDisposed) {
        return;
      }

      switch (event.eventType) {
        case VideoEventType.initialized:
          value = value.copyWith(
            duration: event.duration,
            size: event.size,
            rotationCorrection: event.rotationCorrection,
            isInitialized: event.duration != null,
            errorDescription: null,
          );
          initializingCompleter.complete(null);
          _applyLoopingAsync();
          _applyVolumeAsync();
          _applyPlayPauseAsync();
          break;
        case VideoEventType.completed:
          pauseAsync().then((void pauseResult) => seekToAsync(value.duration));
          break;
        case VideoEventType.bufferingUpdate:
          value = value.copyWith(buffered: event.buffered);
          break;
        case VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case VideoEventType.bufferingEnd:
          value = value.copyWith(isBuffering: false);
          break;
        case VideoEventType.unknown:
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj as PlatformException;
      value = VideoPlayerValue.erroneous(e.message!);
      _timer?.cancel();
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    _eventSubscription = VideoPlayerPlatform.instance
        .videoEventsFor(_textureId)
        .listen(eventListener, onError: errorListener);

    return initializingCompleter.future;
  }

  Future<void> disposeAsync() async {
    if (_isDisposed) {
      return;
    }

    if (_creatingCompleter != null) {
      await _creatingCompleter!.future;
      if (!_isDisposed) {
        _isDisposed = true;
        _timer?.cancel();
        await _eventSubscription?.cancel();
        await VideoPlayerPlatform.instance.dispose(_textureId);
      }
      _lifeCycleObserver?.dispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  Future<void> playAsync() async {
    if (value.position == value.duration) {
      await seekToAsync(Duration.zero);
    }
    value = value.copyWith(isPlaying: true);
    await _applyPlayPauseAsync();
  }

  Future<void> pauseAsync() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPauseAsync();
  }

  Future<void> seekToAsync(Duration position) async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    if (position > value.duration) {
      position = value.duration;
    } else if (position < Duration.zero) {
      position = Duration.zero;
    }
    await VideoPlayerPlatform.instance.seekTo(_textureId, position);
    _updatePosition(position);
  }

  Future<void> setLoopingAsync(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLoopingAsync();
  }

  Future<void> setVolumeAsync(double volume) async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    await VideoPlayerPlatform.instance.setVolume(_textureId, value.volume);
  }

  Future<void> setPlaybackSpeedAsync(double speed) async {
    if (speed < 0) {
      throw ArgumentError.value(
        speed,
        'Negative playback speeds are generally unsupported.',
      );
    } else if (speed == 0) {
      throw ArgumentError.value(
        speed,
        'Zero playback speed is generally unsupported. Consider using [pause].',
      );
    }

    value = value.copyWith(playbackSpeed: speed);
    await _applyPlaybackSpeedAsync();
  }

  @override
  void removeListener(VoidCallback listener) {
    if (!_isDisposed) {
      super.removeListener(listener);
    }
  }

  Future<void> _applyVolumeAsync() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    VideoPlayerPlatform.instance.setVolume(_textureId, value.volume);
  }

  Future<void> _applyPlaybackSpeedAsync() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    if (!value.isPlaying) {
      return;
    }

    await VideoPlayerPlatform.instance.setPlaybackSpeed(_textureId, value.playbackSpeed);
  }

  Future<void> _applyLoopingAsync() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    await VideoPlayerPlatform.instance.setLooping(_textureId, value.isLooping);
  }

  Future<void> _applyPlayPauseAsync() async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    if (value.isPlaying) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(microseconds: 500), (Timer timer) async {
        if (_isDisposed) {
          return;
        }
        final Duration? newPosition = await position;
        if (newPosition == null) {
          return;
        }
        _updatePosition(newPosition);
      });

      await _applyPlaybackSpeedAsync();
    }
    else {
      _timer?.cancel();
      await VideoPlayerPlatform.instance.pause(_textureId);
    }
  }

  void _updatePosition(Duration duration) {
    value = value.copyWith(duration: duration);
  }

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