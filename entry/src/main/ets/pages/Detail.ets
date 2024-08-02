import { display,  promptAction } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { common, wantAgent, WantAgent } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { LibraryItem, Chapter, Progress, PlayItem, Track, UpdateProgress } from '../api/Interface'
import { getItem, getPlayItem, updateProgress } from '../api/Api'
import { getPixelMap } from '../util/fs'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

function formatDuration(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  let formattedTime = '';
  if (hours > 0) {
    formattedTime += `${hours} hr `;
  }
  formattedTime += `${minutes} min`;

  return formattedTime;
}

@Component
export default struct Detail {
  @State displayWidth: number = 0
  @Consume startPlayingTransfer: boolean
  @State coverWidth: string = "20%"
  @State descriptionLine: number = 0
  @Consume allProgress: Progress[]
  @Consume itemTransfer: LibraryItem
  @Consume isPlayingTransfer: boolean
  @Consume nowPlayingItem: LibraryItem
  @Consume nowPlayingChapters: Chapter[]
  @Consume showProgressTransfer: boolean
  @Consume avPlayer: media.AVPlayer | null
  @Consume playTitle: string
  @Consume server: string
  @Consume apitoken: string | null
  @Consume nowPlayingTracks: Track[]
  @Consume nowPlayingIndex: number
  @Consume nowPlayingDuration: number
  @Consume nowPlayedTime: number
  @Consume nowPlayedProgress: number
  @Consume nowTrackStartTime: number
  @State elapsedTime: number = 0
  @Consume showPlayTransfer: boolean
  @Consume session: AVSessionManager.AVSession | null
  @State startTime: number = 0

  async setSessionInfo() {
    let metadata: AVSessionManager.AVMetadata = {
      assetId: '0',
      title: this.nowPlayingChapters[this.nowPlayingIndex].title,
      mediaImage: getPixelMap(filesDir + `/covers/${this.nowPlayingItem.id}.jpg`),
      duration: this.nowPlayingTracks[this.nowPlayingIndex].duration * 1000,
      artist: this.nowPlayingItem.media.metadata.authorName,
      skipIntervals: 10
    };
    this.session!.setAVMetadata(metadata).then(() => {
      console.info(`SetAVMetadata successfully`);
    }).catch((err: BusinessError) => {
      console.error(`Failed to set AVMetadata. Code: ${err.code}, message: ${err.message}`);
    });
  }

  async setPlaybackState(state: number){
    let playbackState: AVSessionManager.AVPlaybackState = {
      state: state,
      position: {
        elapsedTime: this.nowPlayedTime * 1000,
        updateTime: new Date().getTime(),
      },
      duration: this.nowPlayingTracks[this.nowPlayingIndex].duration * 1000,
      speed: 1.0,
    };
    this.session!.setAVPlaybackState(playbackState, (err) => {
      if (err) {
        console.error(`Failed to set AVPlaybackState. Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info(`SetAVPlaybackState successfully`);
      }
    });
  }

  setSessionCallback() {
    this.session!.on('play', () => {
      this.isPlayingTransfer = !this.isPlayingTransfer
      this.avPlayer!.play()
    });
    this.session!.on('pause', () => {
      this.isPlayingTransfer = !this.isPlayingTransfer
      this.avPlayer!.pause()
    });
    this.session!.on('stop', async () => {
      this.startPlayingTransfer = false
      this.isPlayingTransfer = false
      this.showPlayTransfer = false
      this.avPlayer!.stop()
      await this.session!.deactivate()
    });
    this.session!.on('playPrevious', async () => {
      await this.avPlayer!.reset();
      if (this.nowPlayingIndex - 1 < 0) {
        promptAction.showToast({
          message: '已经是第一个',
          duration: 500
        });
      } else {
        this.nowPlayingIndex--
        this.playTitle = this.nowPlayingChapters[this.nowPlayingIndex].title
        this.nowPlayedTime = 0
        this.nowTrackStartTime = this.nowPlayingTracks[this.nowPlayingIndex].startOffset
        this.avPlayer!.url =
          this.server + this.nowPlayingTracks[this.nowPlayingIndex].contentUrl + "?token=" + this.apitoken
        this.setSessionInfo()
      }
    });
    this.session!.on('playNext', async () => {
      await this.avPlayer!.reset();
      if (this.nowPlayingIndex + 1 > this.nowPlayingTracks.length - 1) {
        promptAction.showToast({
          message: '已经是最后一个',
          duration: 500
        });
      } else {
        this.nowPlayingIndex++
        this.playTitle = this.nowPlayingChapters[this.nowPlayingIndex].title
        this.nowPlayedTime = 0
        this.nowTrackStartTime = this.nowPlayingTracks[this.nowPlayingIndex].startOffset
        this.avPlayer!.url =
          this.server + this.nowPlayingTracks[this.nowPlayingIndex].contentUrl + "?token=" + this.apitoken
        this.setSessionInfo()
      }
    });
    this.session!.on('setSpeed', (time) => {
      console.log('触发setSpeed行为。')
    });

    this.session!.off('seek');
    this.session!.off('setLoopMode');
    this.session!.off('toggleFavorite');
    this.session!.off('handleKeyEvent');
    this.session!.off('commonCommand');
  }

  startContinuousTask() {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.audiobookshelf.shanyan",
          abilityName: "com.audiobookshelf.shanyan.EntryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
        console.info(`长时任务启动。`);
      }).catch((err: BusinessError) => {
        console.error(`长时任务出错，代码 ${err.code}，错误信息 ${err.message}`);
      });
    });
  }

  stopContinuousTask() {
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      console.info(`长时任务停止。`);
    }).catch((err: BusinessError) => {
      console.error(`长时任务出错，代码 ${err.code}，错误信息 ${err.message}`);
    });
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('durationUpdate', (duration: number) => {
      this.nowPlayingDuration = duration / 1000
    })
    avPlayer.on('timeUpdate', async (time: number) => {
      this.elapsedTime += 100
      this.nowPlayedTime = time / 1000
      this.nowPlayedProgress = this.nowPlayedTime / this.nowPlayingDuration * 100
      if (this.elapsedTime >= 10000) {
        let upProgress: UpdateProgress = {
          duration: 0,
          currentTime: 0,
          progress: 0
        }
        for (let element of this.allProgress) {
          if (element.libraryItemId === this.nowPlayingItem.id) {
            element.duration = this.nowPlayingItem.media.duration
            element.currentTime = this.nowTrackStartTime + this.nowPlayedTime
            element.progress = element.currentTime / element.duration
            upProgress.duration = element.duration
            upProgress.currentTime = element.currentTime
            upProgress.progress = element.progress
            break
          }
        }
        console.log("当前时间", upProgress.currentTime)
        console.log("当前进度", upProgress.progress)
        await updateProgress(this.nowPlayingItem.id, upProgress)
        this.elapsedTime = 0
      }
    })
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      console.info(`播放器跳转成功，当前时间为 ${seekDoneTime}`);
    })
    avPlayer.on('error', (err: BusinessError) => {
      console.error(`播放器出现错误，code is ${err.code}, message is ${err.message}`);
      avPlayer.reset();
    })
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          console.info('播放器重置。');
          this.elapsedTime = 0
          this.startTime = 0
          break;
        case 'initialized':
          console.info('播放器初始化。');
          avPlayer.prepare();
          break;
        case 'prepared':
          console.info('播放器就绪。');
          this.startContinuousTask();
          this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PREPARE)
          this.avPlayer!.seek(this.startTime * 1000)
          if (this.isPlayingTransfer === true) {
            avPlayer.play()
          } else {
            avPlayer.pause()
          }
          break;
        case 'playing':
          console.info('播放器开始播放。');
          this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
          break;
        case 'paused':
          console.info('播放器暂停。');
          this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
          break;
        case 'completed':
          console.info('播放完毕。');
          await avPlayer.reset();
          if (this.nowPlayingIndex + 1 > this.nowPlayingTracks.length - 1) {
            avPlayer.stop()
          } else {
            this.nowPlayingIndex++
            this.playTitle = this.nowPlayingTracks[this.nowPlayingIndex].title
            avPlayer.url =
              this.server + this.nowPlayingTracks[this.nowPlayingIndex].contentUrl + "?token=" + this.apitoken
            this.nowPlayedTime = 0
            this.nowTrackStartTime = this.nowPlayingTracks[this.nowPlayingIndex].startOffset
            avPlayer.prepare()
          }
          break;
        case 'stopped':
          console.info('播放器停止。');
          this.stopContinuousTask();
          this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_STOP)
          await avPlayer.reset();
          break;
        case 'released':
          console.info('播放器释放。');
          break;
        default:
          console.info('播放器状态未知。');
          break;
      }
    })
  }

  async getPlayContent(playItem: PlayItem): Promise<string> {
    let index: number = 0
    this.nowPlayingTracks = playItem.audioTracks
    for (let track of playItem.audioTracks) {
      if (track.startOffset > playItem.currentTime) {
        index = track.index - 2
        console.log("找到当前音轨序号为" + index + "，起始位置为" + playItem.audioTracks[index].startOffset)
        break
      }
    }
    let url: string = this.server + playItem.audioTracks[index].contentUrl + "?token=" + this.apitoken
    this.playTitle = playItem.chapters[index].title
    this.nowTrackStartTime = playItem.audioTracks[index].startOffset
    console.log("找到音频Url为", url)
    this.nowPlayingIndex = index
    this.nowPlayedTime = playItem.currentTime - playItem.audioTracks[index].startOffset
    console.log("起始位置为", this.nowPlayedTime * 1000)
    return url
  }

  getProgressById(itemId: string): Progress {
    let progress: Progress = {
      id: '',
      libraryItemId: itemId,
      episodeId: '',
      duration: 0,
      progress: 0,
      currentTime: 0,
      isFinished: false,
      hideFromContinueListening: false,
      lastUpdate: 0,
      startedAt: 0,
      finishedAt: null
    }
    for (let element of this.allProgress) {
      if (element.libraryItemId === itemId) {
        progress = element
        progress.progress = Math.round(element.progress * 100) / 100
        break
      }
    }
    return progress
  }

  getDuration(itemId: string): string {
    let duration = ''
    if (this.getProgressById(itemId).currentTime === 0) {
      duration = "未听过"
    } else if (this.getProgressById(itemId).isFinished === true) {
      duration = "已听完"
    } else {
      duration =
        "剩余 " + formatDuration(this.getProgressById(itemId).duration - this.getProgressById(itemId).currentTime)
    }
    return duration
  }

  async aboutToAppear() {
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    if (this.displayWidth >= 320 && this.displayWidth < 600) {
      this.coverWidth = "80%"
      this.descriptionLine = 5
    } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
      this.coverWidth = "280"
      this.descriptionLine = 4
    } else if (this.displayWidth >= 840) {
      this.coverWidth = "280"
      this.descriptionLine = 3
    }
    this.session = await AVSessionManager.createAVSession(context, 'AUDIO_PLAY', 'audio');
    this.setSessionCallback()
  }

  build() {
    Column() {
      Image(this.showProgressTransfer === false ?
      fileUri.getUriFromPath(filesDir + `/covers/${this.itemTransfer.id}.jpg`) : $rawfile('nocover.jpg'))
        .alt($rawfile('nocover.jpg'))
        .width(this.coverWidth)
        .aspectRatio(1)
        .borderRadius(10)
        .objectFit(ImageFit.Fill)
        .margin({ top: 20 })
      Column() {
        Text(this.itemTransfer.media.metadata.title)
          .fontSize(28)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.itemTransfer.media.metadata.subtitle)
          .fontSize(18)
          .fontColor('#E5ECF2')
          .margin({ top: 5 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('80%')

      Column() {
        Column() {
          Row() {
            Button({ type: ButtonType.Normal }) {
              Text("播放")
                .fontSize(18)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .backgroundColor(Color.Green)
            .borderRadius(5)
            .width('100%')
            .height(40)
            .layoutWeight(1)
            .onClick(async () => {
              this.isPlayingTransfer = true
              await this.avPlayer!.reset()
              this.setAVPlayerCallback(this.avPlayer!);
              this.nowPlayingChapters = await getItem(this.itemTransfer.id)
              this.nowPlayingItem = this.itemTransfer
              let playItem: PlayItem = await getPlayItem(this.nowPlayingItem.id)
              let url: string = await this.getPlayContent(playItem)
              this.startTime = this.nowPlayedTime
              this.avPlayer!.url = url
              this.setSessionInfo()
              this.startPlayingTransfer = true
              await this.session!.activate()
            })

            Button({ type: ButtonType.Normal }) {
              Image($rawfile('download.png'))
                .width(30)
                .height(30)
            }
            .backgroundColor('#232323')
            .borderRadius(5)
            .width(40)
            .height(40)
            .margin({ left: 13 })

            Button({ type: ButtonType.Normal }) {
              Image($rawfile('list.png'))
                .width(30)
                .height(30)
            }
            .backgroundColor('#232323')
            .borderRadius(5)
            .width(40)
            .height(40)
            .margin({ left: 13 })

            Button({ type: ButtonType.Normal }) {
              Image($rawfile('more.png'))
                .width(30)
                .height(30)
            }
            .backgroundColor('#232323')
            .borderRadius(5)
            .width(40)
            .height(40)
            .margin({ left: 13 })
          }
          .width('100%')
          .height('auto')

          Column() {
            Text(`你的进度：${this.getProgressById(this.itemTransfer.id).progress * 100}%`)
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Text(this.getDuration(this.itemTransfer.id))
              .fontSize(12)
              .fontColor('#8F9396')
          }
          .backgroundColor('#232323')
          .borderRadius(5)
          .width('100%')
          .height(40)
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .width('100%')
        .height(92)
        .justifyContent(FlexAlign.SpaceBetween)

        Column() {
          Row() {
            Row() {
              Text("作者")
                .fontSize(14)
                .fontColor('#8F9396')
                .width('auto')
                .height('auto')
                .textAlign(TextAlign.Start)
              Text(this.itemTransfer.media.metadata.authorName)
                .fontSize(14)
                .fontColor(Color.White)
                .width('100%')
                .height('auto')
                .layoutWeight(1)
                .margin({ left: 10 })
                .padding({ right: 15 })
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .decoration({ type: TextDecorationType.Underline, color: Color.White })
            }
            .width('50%')
            .justifyContent(FlexAlign.Start)

            Row() {
              Text("时长")
                .fontSize(14)
                .fontColor('#8F9396')
                .width('auto')
                .height('auto')
                .textAlign(TextAlign.Start)
              Text(formatDuration(this.itemTransfer.media.duration))
                .fontSize(14)
                .fontColor(Color.White)
                .width('100%')
                .height('auto')
                .layoutWeight(1)
                .margin({ left: 10 })
                .padding({ right: 15 })
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('50%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row() {
            Row() {
              Text("演播")
                .fontSize(14)
                .fontColor('#8F9396')
                .width('auto')
                .height('auto')
                .textAlign(TextAlign.Start)
              Text(this.itemTransfer.media.metadata.narratorName)
                .fontSize(14)
                .fontColor(Color.White)
                .width('100%')
                .height('auto')
                .layoutWeight(1)
                .margin({ left: 10 })
                .padding({ right: 15 })
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .decoration({ type: TextDecorationType.Underline, color: Color.White })
            }
            .width('50%')
            .justifyContent(FlexAlign.Start)

            Row() {
              Text("流派")
                .fontSize(14)
                .fontColor('#8F9396')
                .width('auto')
                .height('auto')
                .textAlign(TextAlign.Start)
              Text(this.itemTransfer.media.metadata.genres.toString())
                .fontSize(14)
                .fontColor(Color.White)
                .width('100%')
                .height('auto')
                .layoutWeight(1)
                .margin({ left: 10 })
                .padding({ right: 15 })
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .decoration({ type: TextDecorationType.Underline, color: Color.White })
            }
            .width('50%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row() {
            Text("年份")
              .fontSize(14)
              .fontColor('#8F9396')
              .width('auto')
              .height('auto')
              .textAlign(TextAlign.Start)
            Text(this.itemTransfer.media.metadata.publishedYear)
              .fontSize(14)
              .fontColor(Color.White)
              .width('100%')
              .height('auto')
              .layoutWeight(1)
              .margin({ left: 10 })
              .padding({ right: 15 })
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('50%')
          .justifyContent(FlexAlign.Start)
        }
        .margin({ top: 10 })
        .width('100%')
        .height(70)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text("\u3000\u3000" +
          this.itemTransfer.media?.metadata.description)
            .fontSize(14)
            .fontColor(Color.White)
            .width("100%")
            .height('auto')
            .maxLines(this.descriptionLine)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .margin({ top: 10 })
        .width("100%")
        .height(100)
      }
      .width('80%')
      .height('38%')
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor("#333333")
  }
}