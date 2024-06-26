import 'video_player_platform_view_platform_interface.dart';

class VideoPlayerPlatformView {
  Future<String?> getPlatformVersion() {
    return VideoPlayerPlatformViewPlatform.instance.getPlatformVersion();
  }
}
