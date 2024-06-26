import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import PlatformView from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { DVModel } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicView';
import { createDVModelFromJson } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicViewJson';
import VideoPlayerController from './VideoPlayerController';
import { VideoPlayerView } from './VideoPlayerView';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { DVModelJson } from './DynamicUtils';
import { DynamicUtils } from './DynamicUtils';


@Builder
function createVideoPlayerView(param : Params) {
  VideoPlayerView({param:param});
}

export class VideoPlatformPlayerView extends PlatformView {

  private controller : VideoPlayerController | null = null;
  private binding: FlutterPluginBinding | null = null;
  private url : string | null = null;
  private viewId : number = 0;

  constructor(context: Context, viewId: ESObject, args: ESObject,binding: FlutterPluginBinding) {
    super();
    this.viewId = viewId;
    this.binding = binding;
    this.url = args.get('url');
    this.controller = new VideoPlayerController(this.binding.getBinaryMessenger(),viewId);
  }

  ohosWebView: DVModelJson = new DVModelJson(
    "other",
    [],
    {
      src: "",
      viewId : this.viewId,
      url : this.url,
      controller : this.controller
    },
    {},
    createVideoPlayerView
  )

  private ohosModel = createDVModelFromJson(this.ohosWebView);

  getView(): DVModel {
    return this.ohosModel;
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

