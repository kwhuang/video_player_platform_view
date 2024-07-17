import { BinaryMessenger,EventChannel,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  StandardMessageCodec } from '@ohos/flutter_ohos';
import BasicMessageChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';

//操作
export default class VideoPlayerController implements StreamHandler,MethodCallHandler{

  private binaryMessenger: BinaryMessenger | null = null;
  private eventChannel : EventChannel | null = null;
  private eventSink : EventSink | null = null;
  private playerChannel : MethodChannel | null = null;
  public operationCallBack : ((args: ESObject) => void) | null = null;
  public viewId : ESObject = null;

  constructor(binaryMessenger: BinaryMessenger,viewId:ESObject) {
    this.binaryMessenger = binaryMessenger;
    this.viewId = viewId;
    try {
      this.eventChannel = new EventChannel(binaryMessenger,"beautydata.com/videoPlayer/event/" + viewId);
      this.eventChannel.setStreamHandler(this);
      this.playerChannel = new MethodChannel(binaryMessenger,"beautydata.com/videoPlayer/channel/" + viewId);
      this.playerChannel.setMethodCallHandler(this);
    } catch (e) {
      console.log("失败"+e.toString());
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "play") {
      this.play(call.args.get('url'));
      result.success(true);
    } else if (call.method == "pause") {
      this.pause(call.args.get('url'));
      result.success(true);
    } else if (call.method == "resume") {
      this.resume(call.args.get('url'));
      result.success(true);
    }else if (call.method == "stop") {
      this.stop(call.args.get('url'));
      result.success(true);
    }else if (call.method == "seekTo") {
      this.seekTo(call.args.get('url'),call.args.get('progress'));
      result.success(true);
    } else if (call.method == "loop") {
      this.setLoop(call.args.get('url'),call.args.get('loop'));
      result.success(true);
    }else {
      result.notImplemented();
    }
  }

  onListen(args: ESObject, events: EventSink): void {
    this.eventSink = events;
    events.success({});
  }

  onCancel(args: ESObject): void {
    this.eventSink = null;
  }

  callBack(args:ESObject) {
    if (this.operationCallBack != null) {
      this.operationCallBack!(args);
    }
  }

  sendEvent(args: ESObject) {
    this.eventSink?.success(args);
  }

  play(url : string | null) {
    this.callBack({
      'type' : 'play_url',
      'url' : url
    });
  }

  pause(url : string | null) {
    this.callBack({
      'type' : 'stop',
      'url' : url
    });
  }

  resume(url : string | null) {
    console.log("播放器-resume" + url?.toString());
    this.callBack({
      'type' : 'resume',
      'url' : url
    });
  }

  stop(url: string | null) {
    console.log("播放器-stop" + url?.toString());
    this.callBack({
      'type' : 'stop',
      'url' : url
    });
  }

  seekTo(url: string | null, progress : string | null) {
    console.log("播放器-seekTo" + progress?.toString());
    this.callBack({
      'type' : 'seekTo',
      'url' : url,
      'progress' : progress
    });
  }

  setLoop(url: string | null,loop : boolean | null) {
    if (loop != null) {
      this.callBack({
        'type' : 'play_loop',
        'url' : url,
        'loop' : loop
      });
    }
  }
}