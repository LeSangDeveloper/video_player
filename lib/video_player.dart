import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player_controller.dart';
import 'dart:math' as math;

import 'package:video_player/video_player_platform_interface.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer(this.controller, {Key? key}) : super(key: key);

  final VideoPlayerController controller;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.getTextureId();
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  late VoidCallback _listener;
  late int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.getTextureId();
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    _textureId = widget.controller.getTextureId();
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == VideoPlayerController.kUninitializedTextureId
        ? Container()
        : _VideoPlayerWithRotation(
      rotation: widget.controller.value.rotationCorrection,
      child: VideoPlayerPlatform.instance.buildView(_textureId),
    );
  }
}

class _VideoPlayerWithRotation extends StatelessWidget {
  const _VideoPlayerWithRotation(
      {Key? key, required this.rotation, required this.child})
      : super(key: key);
  final int rotation;
  final Widget child;

  @override
  Widget build(BuildContext context) => rotation == 0
      ? child
      : Transform.rotate(
    angle: rotation * math.pi / 180,
    child: child,
  );
}