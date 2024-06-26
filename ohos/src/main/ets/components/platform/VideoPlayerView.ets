import { IjkMediaPlayer } from "@ohos/ijkplayer";
import { OnPreparedListener } from "@ohos/ijkplayer";
import { OnVideoSizeChangedListener } from "@ohos/ijkplayer";
import { OnCompletionListener } from "@ohos/ijkplayer";
import { OnBufferingUpdateListener } from "@ohos/ijkplayer";
import { OnErrorListener, OnTimedTextListener } from "@ohos/ijkplayer";
import { OnInfoListener } from "@ohos/ijkplayer";
import { OnSeekCompleteListener } from "@ohos/ijkplayer";
import { LogUtils } from "@ohos/ijkplayer"
import prompt from '@ohos.promptAction';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import VideoPlayerController from './VideoPlayerController';
import { DynamicUtils } from './DynamicUtils';


export enum PlayStatus {
  INIT,
  PLAY,
  PAUSE,
  DONE
}

let CONTROL_PlayStatus = PlayStatus.INIT;
let PROGRESS_MAX_VALUE: number = 100;
let mIjkMediaPlayer = IjkMediaPlayer.getInstance();
let updateProgressTimer: number = 0;

@Entry
@Component
export struct VideoPlayerView {


  public param : Params | null = null;
  @State progressValue: number = 0;
  @State currentTime: string = "00:00";
  @State totalTime: string = "00:00";
  @State loadingVisible: Visibility = Visibility.None;
  @State replayVisible: Visibility = Visibility.None;
  @State slideEnable: boolean = false;
  @State aspRatio: number = 0.5;
  @State mContext: object | undefined = undefined;
  @State mFirst: boolean = true;
  @State mDestroyPage: boolean = false;
  @State playSpeed: string = '1f';
  @State oldSeconds: number = 0;
  @State isSeekTo: boolean = false;
  @State isCurrentTime: boolean = false;
  private videoUrl: string = '';
  private playerChannel : VideoPlayerController | null = null;

  aboutToAppear() {
    this.pause();
    LogUtils.getInstance().LOGI("aboutToAppear");
    if (this.param != null) {
      this.playerChannel = DynamicUtils.getParams(this.param!.platformView,'controller');
      this.videoUrl = DynamicUtils.getParams(this.param!.platformView,'url');
      this.playerChannel?.setOperationCall(
        (param : ESObject) => {
          let type : string | null = DynamicUtils.getParams(param,'type');
          let url : string | null = DynamicUtils.getParams(param,'url');
          switch (type) {
            case 'play_url' : {
              this.videoUrl = url??'';
              this.startPlayOrResumePlay();
            }
              break;
            case 'play' : {
              this.startPlayOrResumePlay();
            }
              break;
            case 'pause' : {
              this.pause();
            }
              break;
            case 'resume' : {
              this.startPlayOrResumePlay();
            }
              break;
            case 'seekTo' : {
              let progress : string = DynamicUtils.getParams(param,'progress');
              this.seekTo(progress);
            }
              break;

          }
        });
      this.playerChannel?.addChannelListener();
    }
  }

  aboutToDisappear() {
    LogUtils.getInstance().LOGI("aboutToDisappear");
    this.mDestroyPage = true;
    mIjkMediaPlayer.setScreenOnWhilePlaying(false);
    if (CONTROL_PlayStatus != PlayStatus.INIT) {
      this.stop();
    }
  }

  onPageShow() {
    if (this.mContext && !this.mFirst) {
      this.startPlayOrResumePlay();
    }
  }

  onPageHide() {
    this.pause();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Auto, justifyContent: FlexAlign.Start }) {
        XComponent({
          id: 'xcomponentId',
          type: 'surface',
          libraryname: 'ijkplayer_napi',
        })
          .onLoad((event?: object) => {
            if (!!event) {
              this.initDelayPlay(event);
            }
          })
          .onDestroy(() => {
            this.pause();
          })
          .width('100%')
      }
      LoadingProgress()
        .width('120px')
        .height('120px')
        .visibility(this.loadingVisible)
        .border({ width: 0 })
        .borderStyle(BorderStyle.Dashed)
    }.width('100%').height('100%').backgroundColor('#000000').clip(true)
  }

  private initDelayPlay(context: object) {
    this.mContext = context;
    let that = this;
    LogUtils.getInstance().LOGI("initDelayPlay:" + this.param);
    setTimeout(() => {
      that.startPlayOrResumePlay();
      that.mFirst = false;
    }, 300)
  }

  private startPlayOrResumePlay() {
    this.mDestroyPage = false;
    LogUtils.getInstance().LOGI("startPlayOrResumePlay start CONTROL_PlayStatus:" + CONTROL_PlayStatus)
    if (CONTROL_PlayStatus == PlayStatus.INIT) {
      this.stopProgressTask();
      this.startProgressTask();
      this.play(this.videoUrl.toString());
    }
    if (CONTROL_PlayStatus == PlayStatus.PAUSE) {
      mIjkMediaPlayer.start();
      this.setProgress()
    }
  }

  private completionNum(num: number): string | number {
    if (num < 10) {
      return '0' + num;
    } else {
      return num;
    }
  }

  private stringForTime(timeMs: number): string {
    let totalSeconds: number | string = (timeMs / 1000);
    let newSeconds: number | string = totalSeconds % 60;
    let minutes: number | string = (totalSeconds / 60) % 60;
    let hours: number | string = totalSeconds / 3600;
    LogUtils.getInstance().LOGI("stringForTime hours:" + hours + ",minutes:" + minutes + ",seconds:" + newSeconds);
    hours = this.completionNum(Math.floor(Math.floor(hours * 100) / 100));
    minutes = this.completionNum(Math.floor(Math.floor(minutes * 100) / 100));
    newSeconds = Math.floor(Math.floor(newSeconds * 100) / 100)
    if (this.isCurrentTime) {
      if (this.oldSeconds < newSeconds || newSeconds === 0 || this.isSeekTo) {
        this.oldSeconds = newSeconds
      } else {
        newSeconds = this.oldSeconds
      }
    }
    newSeconds = this.completionNum(newSeconds);
    if (hours > 0) {
      return hours + ":" + minutes + ":" + newSeconds;
    } else {
      return minutes + ":" + newSeconds;
    }
  }

  private setProgress() {
    let position = mIjkMediaPlayer.getCurrentPosition();
    let duration = mIjkMediaPlayer.getDuration();
    let pos = 0;
    if (duration > 0) {
      this.slideEnable = true;
      let curPercent = position / duration;
      pos = curPercent * 100;
      this.progressValue = pos;
    }
    LogUtils.getInstance()
      .LOGI("setProgress position:" + position + ",duration:" + duration + ",progressValue:" + pos);
    this.totalTime = this.stringForTime(duration);
    if (position > duration) {
      position = duration;
    }
    this.isCurrentTime = true;
    this.currentTime = this.stringForTime(position);
    if (duration > 0) {
      this.playerChannel?.sendEvent({
        'type' : 'progress',
        'position' : position,
        'duration' : duration,
        'progress' : this.currentTime,
        'viewId' : this.playerChannel.viewId,
        'url' : this.videoUrl
      });
    }
    this.isCurrentTime = false
  }

  private startProgressTask() {
    let that = this;
    updateProgressTimer = setInterval(() => {
      LogUtils.getInstance().LOGI("startProgressTask");
      if (!that.mDestroyPage) {
        that.setProgress();
      }
    }, 300);
  }

  private stopProgressTask() {
    LogUtils.getInstance().LOGI("stopProgressTask");
    clearInterval(updateProgressTimer);
  }

  private showLoadIng() {
    this.loadingVisible = Visibility.Visible;
    this.replayVisible = Visibility.None;
  }

  private hideLoadIng() {
    this.loadingVisible = Visibility.None;
    this.replayVisible = Visibility.None;
  }

  private showRePlay() {
    this.loadingVisible = Visibility.None;
    this.replayVisible = Visibility.Visible;
  }

  private play(url: string) {
    let that = this;
    that.showLoadIng();
    //设置XComponent回调的context
    if (!!this.mContext) {
      mIjkMediaPlayer.setContext(this.mContext, 'xcomponentId');
    }
    if (CONTROL_PlayStatus == PlayStatus.INIT) {
      mIjkMediaPlayer.reset();
    }
    CONTROL_PlayStatus = PlayStatus.PLAY;
    //设置debug模式
    mIjkMediaPlayer.setDebug(true);
    //初始化配置
    mIjkMediaPlayer.native_setup();
    //设置视频源
    mIjkMediaPlayer.setDataSource(url);
    //设置视频源http请求头
    let headers = new Map([
      ["user_agent", "Mozilla/5.0 BiliDroid/7.30.0 (bbcallen@gmail.com)"],
      ["referer", "https://www.bilibili.com"]
    ]);
    mIjkMediaPlayer.setDataSourceHeader(headers);
    //使用精确寻帧 例如，拖动播放后，会寻找最近的关键帧进行播放，很有可能关键帧的位置不是拖动后的位置，而是较前的位置.可以设置这个参数来解决问题
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", "1");
    //预读数据的缓冲区大小
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-buffer-size", "102400");
    //停止预读的最小帧数
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "min-frames", "100");
    //启动预加载
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", "1");
    // 设置无缓冲，这是播放器的缓冲区，有数据就播放
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", "0");
    //跳帧处理,放CPU处理较慢时，进行跳帧处理，保证播放流程，画面和声音同步
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", "5");
    // 最大缓冲cache是3s， 有时候网络波动，会突然在短时间内收到好几秒的数据
    // 因此需要播放器丢包，才不会累积延时
    // 这个和第三个参数packet-buffering无关。
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_cached_duration", "3000");
    // 无限制收流
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", "1");
    mIjkMediaPlayer.setOptionLong(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", "1")
    // 屏幕常亮
    mIjkMediaPlayer.setScreenOnWhilePlaying(true);
    // 设置超时
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "timeout", "10000000");
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "connect_timeout", "10000000");
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "addrinfo_timeout", "10000000");
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_timeout", "10000000");
    // 设置音量
    // mIjkMediaPlayer.setVolume("0.5", "0.5");
    // 变速播放
    mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "soundtouch", "1");
    mIjkMediaPlayer.setSpeed(this.playSpeed);
    let Speed = mIjkMediaPlayer.getSpeed()
    LogUtils.getInstance().LOGI('getSpeed--' + Speed)
    //是否开启循环播放
    mIjkMediaPlayer.setLoopCount(true);
    let mOnVideoSizeChangedListener: OnVideoSizeChangedListener = {
      onVideoSizeChanged: (width: number, height: number, sar_num: number, sar_den: number) => {
        that.aspRatio = width / height;
        LogUtils.getInstance()
          .LOGI("setOnVideoSizeChangedListener-->go:" + width + "," + height + "," + sar_num + "," + sar_den)
        that.hideLoadIng();
      }
    }
    mIjkMediaPlayer.setOnVideoSizeChangedListener(mOnVideoSizeChangedListener);
    let mOnPreparedListener: OnPreparedListener = {
      onPrepared: () => {
        LogUtils.getInstance().LOGI("setOnPreparedListener-->go");
      }
    }
    mIjkMediaPlayer.setOnPreparedListener(mOnPreparedListener);

    let mOnTimedTextListener: OnTimedTextListener = {
      onTimedText: () => {
      }
    }
    mIjkMediaPlayer.setOnTimedTextListener(mOnTimedTextListener)

    let mOnCompletionListener: OnCompletionListener = {
      onCompletion: () => {
        LogUtils.getInstance().LOGI("OnCompletionListener-->go")
        that.showRePlay();
        that.currentTime = that.stringForTime(mIjkMediaPlayer.getDuration());
        that.progressValue = PROGRESS_MAX_VALUE;
        that.slideEnable = false;
        that.stop();
      }
    }
    mIjkMediaPlayer.setOnCompletionListener(mOnCompletionListener);

    let mOnBufferingUpdateListener: OnBufferingUpdateListener = {
      onBufferingUpdate: (percent: number) => {
        LogUtils.getInstance().LOGI("OnBufferingUpdateListener-->go:" + percent);
        let MediaInfo = mIjkMediaPlayer.getMediaInfo()
        LogUtils.getInstance().LOGI('getMediaInfo---' + MediaInfo);
        let VideoWidth = mIjkMediaPlayer.getVideoWidth()
        LogUtils.getInstance().LOGI('getVideoWidth---' + VideoWidth);

        let VideoHeight = mIjkMediaPlayer.getVideoHeight()
        LogUtils.getInstance().LOGI('getVideoHeight---' + VideoHeight);

        let VideoSarNum = mIjkMediaPlayer.getVideoSarNum()
        LogUtils.getInstance().LOGI('getVideoSarNum---' + VideoSarNum);

        let VideoSarDen = mIjkMediaPlayer.getVideoSarDen()
        LogUtils.getInstance().LOGI('getVideoSarDen---' + VideoSarDen);

        let AudioSessionId = mIjkMediaPlayer.getAudioSessionId()
        LogUtils.getInstance().LOGI('getAudioSessionId---' + AudioSessionId);

        let Looping = mIjkMediaPlayer.isLooping()
        LogUtils.getInstance().LOGI('isLooping---' + Looping);
      }
    }
    mIjkMediaPlayer.setOnBufferingUpdateListener(mOnBufferingUpdateListener);

    let mOnSeekCompleteListener: OnSeekCompleteListener = {
      onSeekComplete: () => {
        LogUtils.getInstance().LOGI("OnSeekCompleteListener-->go");
        that.startPlayOrResumePlay();
      }
    }
    mIjkMediaPlayer.setOnSeekCompleteListener(mOnSeekCompleteListener);

    let mOnInfoListener: OnInfoListener = {
      onInfo: (what: number, extra: number) => {
        LogUtils.getInstance().LOGI("OnInfoListener-->go:" + what + "===" + extra);
        that.hideLoadIng();
      }
    }
    mIjkMediaPlayer.setOnInfoListener(mOnInfoListener);


    let mOnErrorListener: OnErrorListener = {
      onError: (what: number, extra: number) => {
        this.stopProgressTask();
        LogUtils.getInstance().LOGI("OnErrorListener-->go:" + what + "===" + extra)
        that.hideLoadIng();
        prompt.showToast({
          message: "亲，视频播放异常，系统开小差咯"
        });
      }
    }


    mIjkMediaPlayer.setOnErrorListener(mOnErrorListener);

    mIjkMediaPlayer.setMessageListener();

    mIjkMediaPlayer.prepareAsync();

    mIjkMediaPlayer.start();
  }

  private pause() {
    if (mIjkMediaPlayer.isPlaying()) {
      mIjkMediaPlayer.pause();
      this.setProgress();
      this.mDestroyPage = true;
      CONTROL_PlayStatus = PlayStatus.PAUSE;
    }
  }

  private stop() {
    CONTROL_PlayStatus = PlayStatus.INIT;
    mIjkMediaPlayer.stop();
    mIjkMediaPlayer.release();
    this.stopProgressTask();
  }

  private seekTo(value: string) {
    mIjkMediaPlayer.seekTo(value);

  }
}