import {
  AbilityPluginBinding,
  FlutterPlugin,
  MethodCall,
  MethodChannel, StandardMessageCodec,
} from '@ohos/flutter_ohos';
import { MethodCallHandler,MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import {
  VideoPlatformPlayerViewFactory
} from '../platform/VideoPlatformPlayerViewFactory';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import VideoPlayerController from '../platform/VideoPlayerController';


/** VideoPlayerPlatformViewPlugin **/
export default class VideoPlayerPlatformViewPlugin implements FlutterPlugin, MethodCallHandler,AbilityAware {
  private channel: MethodChannel | null = null;
  private pluginBinding: FlutterPluginBinding | null = null;
  private factory : VideoPlatformPlayerViewFactory | null = null;
  private playerChannel: MethodChannel | null = null;
  static controllers : Map<ESObject,VideoPlayerController> = new Map<ESObject,VideoPlayerController>();


  onAttachedToAbility(binding: AbilityPluginBinding): void {

  }

  onDetachedFromAbility(): void {

  }

  getUniqueClassName(): string {
    return "VideoPlayerPlatformViewPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = binding;
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "video_player_platform_view");
    this.channel.setMethodCallHandler(this);
    this.factory = new VideoPlatformPlayerViewFactory(StandardMessageCodec.INSTANCE,binding);
    binding.getPlatformViewRegistry().registerViewFactory(
      'video_player_platform_view',
      this.factory
    );
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = null;
    this.factory = null;
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getPlatformVersion") {
      result.success("OpenHarmony ^ ^ ")
    } else {
      result.notImplemented()
    }
  }
}