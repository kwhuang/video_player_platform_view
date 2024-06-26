import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_view/video_player_platform_view.dart';
import 'package:video_player_platform_view/video_player_platform_view_platform_interface.dart';
import 'package:video_player_platform_view/video_player_platform_view_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVideoPlayerPlatformViewPlatform
    with MockPlatformInterfaceMixin
    implements VideoPlayerPlatformViewPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VideoPlayerPlatformViewPlatform initialPlatform = VideoPlayerPlatformViewPlatform.instance;

  test('$MethodChannelVideoPlayerPlatformView is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVideoPlayerPlatformView>());
  });

  test('getPlatformVersion', () async {
    VideoPlayerPlatformView videoPlayerPlatformViewPlugin = VideoPlayerPlatformView();
    MockVideoPlayerPlatformViewPlatform fakePlatform = MockVideoPlayerPlatformViewPlatform();
    VideoPlayerPlatformViewPlatform.instance = fakePlatform;

    expect(await videoPlayerPlatformViewPlugin.getPlatformVersion(), '42');
  });
}
