import { BinaryMessenger,EventChannel, StandardMessageCodec } from '@ohos/flutter_ohos';
import BasicMessageChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';

type VideoOperationCallBack = (param : ESObject) => void;

//操作
export default class VideoPlayerController implements StreamHandler{

  private binaryMessenger: BinaryMessenger | null = null;
  private eventChannel : EventChannel | null = null;
  private eventSink : EventSink | null = null;
  private operationCallBack : VideoOperationCallBack | null = null;
  public viewId : ESObject = null;

  constructor(binaryMessenger: BinaryMessenger,viewId:ESObject) {
    this.binaryMessenger = binaryMessenger;
    this.viewId = viewId;
    try {
      this.eventChannel = new EventChannel(binaryMessenger,"beautydata.com/videoPlayer/event/" + viewId);
      this.eventChannel.setStreamHandler(this);
    } catch (e) {
      console.log("失败"+e.toString());
    }
  }

  onListen(args: ESObject, events: EventSink): void {
    this.eventSink = events;
    events.success({});
  }

  onCancel(args: ESObject): void {
    this.eventSink = null;
  }

  setOperationCall(callBack : VideoOperationCallBack) {
    this.operationCallBack = callBack;
  }

  callBack(args:ESObject) {
    if (this.operationCallBack != null) {
      this.operationCallBack!(args);
    }
  }

  addChannelListener() {
    const self = this;
    const playUrlChannel: BasicMessageChannel<Object> = new BasicMessageChannel<Object>(
      this.binaryMessenger!, "dev.flutter.pigeon.VideoPlayerApi."+ this.viewId +".play.url",StandardMessageCodec.INSTANCE);
    playUrlChannel.setMessageHandler({
      onMessage(msg: Object, reply: Reply<Object>): void {
        console.log("播放器-play" + msg.toString());
        self.callBack({
          'type' : 'play_url',
          'url' : msg.toString()
        });
      }
    });
    const playChannel: BasicMessageChannel<Object> = new BasicMessageChannel<Object>(
      this.binaryMessenger!, "dev.flutter.pigeon.VideoPlayerApi." + this.viewId + ".play",StandardMessageCodec.INSTANCE);
    playChannel.setMessageHandler({
      onMessage(msg: Object, reply: Reply<Object>): void {
        console.log("播放器-pause" + msg.toString());
        self.callBack({
          'type' : 'play',
          'url' : msg.toString()
        });
      }
    });
    const pauseChannel: BasicMessageChannel<Object> = new BasicMessageChannel<Object>(
      this.binaryMessenger!, "dev.flutter.pigeon.VideoPlayerApi." + this.viewId + ".pause",StandardMessageCodec.INSTANCE);
    pauseChannel.setMessageHandler({
      onMessage(msg: Object, reply: Reply<Object>): void {
        console.log("播放器-pause" + msg.toString());
        self.callBack({
          'type' : 'pause',
          'url' : msg.toString()
        });
      }
    });
    const stopChannel: BasicMessageChannel<Object> = new BasicMessageChannel<Object>(
      this.binaryMessenger!, "dev.flutter.pigeon.VideoPlayerApi." + this.viewId + ".stop",StandardMessageCodec.INSTANCE);
    stopChannel.setMessageHandler({
      onMessage(msg: Object, reply: Reply<Object>): void {
        console.log("播放器-stop" + msg.toString());
        self.callBack({
          'type' : 'stop',
          'url' : msg.toString()
        });
      }
    });
    const seekToChannel: BasicMessageChannel<Object> = new BasicMessageChannel<Object>(
      this.binaryMessenger!, "dev.flutter.pigeon.VideoPlayerApi." + this.viewId + ".seekTo",StandardMessageCodec.INSTANCE);
    seekToChannel.setMessageHandler({
      onMessage(msg: Object, reply: Reply<Object>): void {
        console.log("播放器-seekTo" + msg.toString());
        self.callBack({
          'type' : 'play_url',
          'progress' : msg.toString()
        });
      }
    });
  }

  sendEvent(args: ESObject) {
    this.eventSink?.success(args);
  }

}