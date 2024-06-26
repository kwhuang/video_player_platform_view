import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_player_platform_view_platform_interface.dart';

/// An implementation of [VideoPlayerPlatformViewPlatform] that uses method channels.
class MethodChannelVideoPlayerPlatformView extends VideoPlayerPlatformViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('video_player_platform_view');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
