import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_view/video_player_platform_view.dart';
import 'package:video_player_platform_view/video_player_view_controller.dart';

typedef VideoPlayerViewCreatedCallback = void Function(VideoPlayerViewController controller);

class VideoPlayerView extends StatelessWidget {
  final String url;
  final VideoPlayerViewCreatedCallback? onCreated;

  const VideoPlayerView({super.key, this.onCreated, required this.url});

  @override
  Widget build(BuildContext context) {
    return OhosView(
      viewType: 'video_player_platform_view',
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: {'url': url},
      onPlatformViewCreated: (id) async {
        debugPrint('onPlatformViewCreated返回的id:$id');
        VideoPlayerViewController controller = VideoPlayerViewController.init(id, url);
        if (onCreated != null) {
          onCreated!(controller);
        }
      },
    );
  }
}
