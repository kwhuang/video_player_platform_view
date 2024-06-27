import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player_platform_view/video_player_view.dart';
import 'package:video_player_platform_view/video_player_view_controller.dart';

class VideoPlayPage extends StatefulWidget {
  const VideoPlayPage({super.key});

  @override
  State<VideoPlayPage> createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> with WidgetsBindingObserver {
  VideoPlayerViewController? _controller;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller?.play();
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.pause();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  onPressed: () {
                    _controller?.playWithUrl(url: 'http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv');
                  },
                  child: const Text('播放'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  onPressed: () {
                    _controller?.pause();
                  },
                  child: const Text('暂停'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/video_play_page',
                        arguments: {'url': 'http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv'});
                  },
                  child: const Text('跳转视频播放'),
                ),
              ],
            ),
            Container(
              color: Colors.red,
              height: 250,
              child: VideoPlayerView(
                url: 'http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid_demo1080p.flv',
                onCreated: (controller) async {
                  _controller = controller;
                  _controller!.onPlayerEventBroadcast.listen((event) {
                    debugPrint('播放器事件:$event');
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
