import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../enums/video_event_type.dart';
import 'duration_range.dart';

@immutable
class VideoEvent {
  final VideoEventType eventType;
  final Duration? duration;
  final Size? size;
  final int? rotationCorrection;
  final List<DurationRange>? buffered;

  VideoEvent({
    required this.eventType,
    this.duration,
    this.size,
    this.rotationCorrection,
    this.buffered
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VideoEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            duration == other.duration &&
            size == other.size &&
            rotationCorrection == other.rotationCorrection &&
            listEquals(buffered, other.buffered);
  }

  @override
  int get hashCode => Object.hash(
    eventType,
    duration,
    size,
    rotationCorrection,
    buffered,
  );

}