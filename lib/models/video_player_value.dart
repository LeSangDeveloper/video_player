import 'dart:ui';

import 'duration_range.dart';

class VideoPlayerValue {
  static const String _defaultErrorDescription = "defaultErrorDescription";
  final Duration duration;
  final Duration position;
  final List<DurationRange> buffered;
  final bool isPlaying;
  final bool isLooping;
  final bool isBuffering;
  final double volume;
  final double playbackSpeed;
  final String? errorDescription;
  final Size size;
  final int rotationCorrection;
  final bool isInitialized;

  VideoPlayerValue({
    required this.duration,
    this.position = Duration.zero,
    this.buffered = const <DurationRange>[],
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.errorDescription,
    this.size = Size.zero,
    this.rotationCorrection = 0,
    this.isInitialized = false
  });
}