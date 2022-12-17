import 'package:flutter/foundation.dart';

@immutable
class VideoPlayerOptions {
  final bool allowBackgroundPlayback;
  final bool mixWithOthers;

  const VideoPlayerOptions({this.allowBackgroundPlayback = false, this.mixWithOthers = false});
}