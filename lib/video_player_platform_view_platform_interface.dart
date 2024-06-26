import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_player_platform_view_method_channel.dart';

abstract class VideoPlayerPlatformViewPlatform extends PlatformInterface {
  /// Constructs a VideoPlayerPlatformViewPlatform.
  VideoPlayerPlatformViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoPlayerPlatformViewPlatform _instance = MethodChannelVideoPlayerPlatformView();

  /// The default instance of [VideoPlayerPlatformViewPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoPlayerPlatformView].
  static VideoPlayerPlatformViewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoPlayerPlatformViewPlatform] when
  /// they register themselves.
  static set instance(VideoPlayerPlatformViewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
