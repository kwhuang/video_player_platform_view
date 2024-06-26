import { MessageCodec, PlatformView } from '@ohos/flutter_ohos';
import PlatformViewFactory from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformViewFactory';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { VideoPlatformPlayerView } from './VideoPlatformPlayerView';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';

export class VideoPlatformPlayerViewFactory extends PlatformViewFactory {

  private binding: FlutterPluginBinding | null = null;

  constructor(createArgsCodec: MessageCodec<ESObject>, binding: FlutterPluginBinding) {
    super(createArgsCodec);
    this.binding = binding;
  }

  public create(context: Context, viewId: number, args: ESObject): PlatformView {
    return new VideoPlatformPlayerView(context, viewId, args,this.binding!);
  }

  getCreateArgsCodec(): MessageCodec<ESObject> {
    return StandardMessageCodec.INSTANCE;
  }
}
