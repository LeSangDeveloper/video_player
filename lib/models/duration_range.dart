import 'package:flutter/foundation.dart';

@immutable
class DurationRange {
  final Duration start;
  final Duration end;

  const DurationRange(this.start, this.end);

  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'DurationRange')}(start: $start, end: $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DurationRange &&
              runtimeType == other.runtimeType &&
              start == other.start &&
              end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

}