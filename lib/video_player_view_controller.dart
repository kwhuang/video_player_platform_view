import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class VideoPlayerViewController {
  late int _id;
  StreamSubscription? _eventSubscription;
  final StreamController<Map<dynamic, dynamic>> _eventStreamController = StreamController.broadcast();
  Stream<Map<dynamic, dynamic>> get onPlayerEventBroadcast => _eventStreamController.stream;
  String? _playUrl;

  MethodChannel? _playerChannel;

  VideoPlayerViewController.init(int id, String? url) {
    _id = id;
    _playUrl = url;
    _eventSubscription = EventChannel("beautydata.com/videoPlayer/event/$id")
        .receiveBroadcastStream()
        .listen(_eventHandler, onError: _errorHandler);
    _playerChannel = MethodChannel("beautydata.com/videoPlayer/channel/$id");
    _playerChannel?.setMethodCallHandler((call) async {
      debugPrint('鸿蒙那边传过来的method：${call.method},方法参数：${call.arguments}');
    });
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
    try {
      return _playerChannel?.invokeMethod('play', {'url': _playUrl});
    } catch (e, s) {
      debugPrint('播放器play失败：${e.toString()}');
      debugPrint('播放器play失败堆栈：${s.toString()}');
      return null;
    }
  }

  Future<dynamic> play() async {
    try {
      return _playerChannel?.invokeMethod('play', {'url': _playUrl});
    } catch (e, s) {
      debugPrint('播放器play失败：${e.toString()}');
      debugPrint('播放器play失败堆栈：${s.toString()}');
      return null;
    }
  }

  Future<dynamic> pause() async {
    try {
      return _playerChannel?.invokeMethod('pause', {'url': _playUrl});
    } catch (e, s) {
      debugPrint('播放器pause失败：${e.toString()}');
      debugPrint('播放器pause失败堆栈：${s.toString()}');
      return null;
    }
  }

  Future<dynamic> resume() async {
    try {
      return _playerChannel?.invokeMethod('resume', {'url': _playUrl});
    } catch (e, s) {
      debugPrint('播放器resume失败：${e.toString()}');
      debugPrint('播放器resume失败堆栈：${s.toString()}');
      return null;
    }
  }

  Future<dynamic> stop() async {
    try {
      return _playerChannel?.invokeMethod('stop', {'url': _playUrl});
    } catch (e, s) {
      debugPrint('播放器stop失败：${e.toString()}');
      debugPrint('播放器stop失败堆栈：${s.toString()}');
      return null;
    }
  }

  Future<dynamic> seekTo(progress) async {
    try {
      return _playerChannel?.invokeMethod('seekTo', {'url': _playUrl, 'progress': progress});
    } catch (e, s) {
      debugPrint('播放器seekTo失败：${e.toString()}');
      debugPrint('播放器seekTo失败堆栈：${s.toString()}');
      return null;
    }
  }

  Future<dynamic> setLoop(loop) async {
    try {
      return _playerChannel?.invokeMethod('loop', {'url': _playUrl, 'loop': loop});
    } catch (e, s) {
      debugPrint('播放器loop失败：${e.toString()}');
      debugPrint('播放器loop失败堆栈：${s.toString()}');
      return null;
    }
  }
}
