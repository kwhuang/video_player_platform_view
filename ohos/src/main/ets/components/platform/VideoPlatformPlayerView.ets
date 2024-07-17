import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { BuilderParams, DVModel } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicView';
import { createDVModelFromJson } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicViewJson';
import VideoPlayerController from './VideoPlayerController';
import { VideoPlayerView } from './VideoPlayerView';
import { DVModelJson } from './DynamicUtils';
import { DynamicUtils } from './DynamicUtils';


@Builder
function createVideoPlayerView(params: Params) {
  //这里不通过controller传过去，在那边使用getPlayerController获取到的是另外一个新的controller实例对象
  VideoPlayerView({
    param:params,
    controller: (params.platformView as VideoPlatformPlayerView).getPlayerController()
  }).backgroundColor(Color.Yellow);
}

export class VideoPlatformPlayerView extends PlatformView {

  private controller : VideoPlayerController | null = null;
  private binding: FlutterPluginBinding | null = null;
  public url : string | null = null;
  public viewId : number = 0;

  constructor(context: Context, viewId: ESObject, args: ESObject,binding: FlutterPluginBinding) {
    super();
    this.viewId = viewId;
    this.binding = binding;
    this.url = args.get('url');
    this.controller = new VideoPlayerController(this.binding!.getBinaryMessenger(),this.viewId);
  }

  getPlayerController() : VideoPlayerController {
    return this.controller!;
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(createVideoPlayerView);
  }

  onFlutterViewAttached(dvModel: DVModel): void {

  }

  onFlutterViewDetached(): void {

  }

  dispose(): void {
    this.controller?.pause(this.url);
  }

  onInputConnectionLocked(): void {

  }

  onInputConnectionUnlocked(): void {

  }

}

