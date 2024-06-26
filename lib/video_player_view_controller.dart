import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class VideoPlayerViewController {
  late int _id;
  StreamSubscription? _eventSubscription;
  final StreamController<Map<dynamic, dynamic>> _eventStreamController = StreamController.broadcast();
  Stream<Map<dynamic, dynamic>> get onPlayerEventBroadcast => _eventStreamController.stream;
  String? _playUrl;

  VideoPlayerViewController.init(int id, String? url) {
    _id = id;
    _playUrl = url;
    _eventSubscription = EventChannel("beautydata.com/videoPlayer/event/$id")
        .receiveBroadcastStream()
        .listen(_eventHandler, onError: _errorHandler);
  }

  _eventHandler(event) {
    if (event == null) return;
    _eventStreamController.add(event);
  }

  _errorHandler(error) {
    //debugPrint("= error = ${error.toString()}");
  }

  Future<dynamic> playWithUrl({String url = ""}) async {
    _playUrl = url;
    BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.VideoPlayerApi.$_id.play.url',
      const StandardMessageCodec(),
    );
    final List<Object?>? replyList = await channel.send(url) as List<Object?>?;
    debugPrint('播放器-play.url:$_playUrl,\n name:dev.flutter.pigeon.VideoPlayerApi.$_id.play.url');
    return replyList;
  }

  Future<dynamic> play() async {
    BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.VideoPlayerApi.$_id.play',
      const StandardMessageCodec(),
    );
    final replay = await channel.send(_playUrl);
    debugPrint('播放器-play:$_playUrl,\n name:dev.flutter.pigeon.VideoPlayerApi.$_id.play');
    return replay;
  }

  Future<dynamic> pause() async {
    BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.VideoPlayerApi.$_id.pause',
      const StandardMessageCodec(),
    );
    final replay = await channel.send(_playUrl);
    debugPrint('播放器-pause:$_playUrl,\n name:dev.flutter.pigeon.VideoPlayerApi.$_id.pause');
    return replay;
  }

  Future<dynamic> resume() async {
    BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.VideoPlayerApi.$_id.resume',
      const StandardMessageCodec(),
    );
    final replay = await channel.send(_playUrl);
    debugPrint('播放器-resume:$_playUrl,\n name:dev.flutter.pigeon.VideoPlayerApi.$_id.resume');
    return replay;
  }

  Future<dynamic> stop() async {
    BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.VideoPlayerApi.$_id.stop',
      const StandardMessageCodec(),
    );
    final replay = await channel.send(_playUrl);
    debugPrint('播放器-stop:$_playUrl,\n name:dev.flutter.pigeon.VideoPlayerApi.$_id.stop');
    return replay;
  }

  Future<dynamic> seekTo(progress) async {
    BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.VideoPlayerApi.$_id.seekTo',
      const StandardMessageCodec(),
    );
    final replay = await channel.send(progress);
    debugPrint('播放器-seekTo:$_playUrl,\n name:dev.flutter.pigeon.VideoPlayerApi.$_id.seekTo');
    return replay;
  }
}
