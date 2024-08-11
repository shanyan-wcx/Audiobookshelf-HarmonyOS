import { window, promptAction } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { common, wantAgent, WantAgent } from '@kit.AbilityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { bundleManager } from '@kit.AbilityKit';
import {
  LibraryItem,
  Chapter,
  Progress,
  PlayItem,
  Track,
  UpdateProgress,
  UpdateSession,
  Bookmark
} from '../api/Interface'
import {
  getItem,
  getPlayItem,
  updateProgress,
  syncSession,
  closeSession,
  getLibrarieItemsFinished,
  getLibrarieItemsInProgress,
  getCover
} from '../api/Api'
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
  @State displayHeight: number = 0
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
  @Consume apitoken: string
  @Consume nowPlayingTracks: Track[]
  @Consume nowPlayingIndex: number
  @Consume nowPlayingDuration: number
  @Consume nowPlayedTime: number
  @Consume nowPlayedProgress: number
  @Consume nowTrackStartTime: number
  @State elapsedTime: number = 0
  @Consume showPlayTransfer: boolean
  @Consume session: AVSessionManager.AVSession | null
  @Consume startTime: number
  @Consume backPageIndex: number
  @Consume sessionId: string
  @Consume syncTime: number
  @Consume playItem: PlayItem | null
  @State showMore: boolean = false
  @State itemProgress: Progress | null = null
  @State itemDuration: string | null = null
  @Consume selectedLibraryId: string
  @Consume libraryItemsInProgress: LibraryItem[]
  @Consume libraryItemsFinished: LibraryItem[]
  @Consume sidebarShow: boolean
  @State mainWindow: window.Window | null = null
  @State showCover: boolean = true
  @Consume speed: number
  @Consume speedNumber: number
  @Consume sleepTime: number
  @Consume bookmarks: Bookmark[]
  @Consume nowPlayingBookmarks: Bookmark[]

  async setSessionInfo() {
    let metadata: AVSessionManager.AVMetadata = {
      assetId: '0',
      title: this.nowPlayingChapters[this.nowPlayingIndex].title,
      mediaImage: getPixelMap(await getCover(this.nowPlayingItem.id)),
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

  async setPlaybackState(state: number, time?: number) {
    let playbackState: AVSessionManager.AVPlaybackState = {
      state: state,
      duration: this.nowPlayingTracks[this.nowPlayingIndex].duration * 1000,
      speed: this.speedNumber,
    };
    if (time !== undefined) {
      playbackState.position = {
        elapsedTime: time * 1000,
        updateTime: new Date().getTime(),
      }
    }
    this.session!.setAVPlaybackState(playbackState, (err) => {
      if (err) {
        console.error(`设置Session状态失败，Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info("设置Session状态", state);
      }
    });
  }

  async setSessionCallback() {
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
        this.startTime = 0
        this.nowTrackStartTime = this.nowPlayingTracks[this.nowPlayingIndex].startOffset
        this.avPlayer!.url =
          this.server + this.nowPlayingTracks[this.nowPlayingIndex].contentUrl + "?token=" + this.apitoken
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
        this.startTime = 0
        this.nowTrackStartTime = this.nowPlayingTracks[this.nowPlayingIndex].startOffset
        this.avPlayer!.url =
          this.server + this.nowPlayingTracks[this.nowPlayingIndex].contentUrl + "?token=" + this.apitoken
      }
    });
    this.session!.on('seek', (time: number) => {
      this.avPlayer!.seek(time)
      this.isPlayingTransfer === true ?
      this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY, time / 1000) :
      this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE, time / 1000)
    });
    this.session!.on('setSpeed', (time) => {
      console.log('触发setSpeed行为。')
    });
    this.session!.off('setLoopMode');
    this.session!.off('toggleFavorite');
  }

  async startContinuousTask() {
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
        console.info(`启动长时任务。`);
      }).catch((err: BusinessError) => {
        console.error(`启动长时任务出错，代码 ${err.code}，错误信息 ${err.message}`);
      });
    });
  }

  async stopContinuousTask() {
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      console.info(`停止长时任务。`);
    }).catch((err: BusinessError) => {
      console.error(`停止长时任务出错，代码 ${err.code}，错误信息 ${err.message}`);
    });
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('durationUpdate', (duration: number) => {
      this.nowPlayingDuration = duration / 1000
    })
    avPlayer.on('timeUpdate', async (time: number) => {
      this.elapsedTime += 100
      this.nowPlayedTime = time / 1000
      if (this.sleepTime > 0 && this.isPlayingTransfer === true) {
        this.sleepTime -= 0.1
        if (this.sleepTime <= 0) {
          this.avPlayer!.pause()
          this.isPlayingTransfer = false
          this.sleepTime = 0
        }
      }
      this.nowPlayedProgress = this.nowPlayedTime / this.nowPlayingDuration * 100
      if (this.elapsedTime >= 1000) {
        let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
        let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleFlags)
        let upProgress: UpdateProgress = {
          duration: 0,
          currentTime: 0,
          progress: 0,
          isFinished: false
        }
        let updateSession: UpdateSession = {
          deviceInfo: {
            id: '00000000',
            userId: this.playItem!.userId,
            deviceName: deviceInfo.productModel,
            clientName: 'Abs-HarmonyOS',
            clientVersion: bundleInfo.versionName
          },
          mediaPlayer: "avPlayer",
          currentTime: 0,
          timeListened: new Date().getTime() / 1000 - this.syncTime
        }
        for (let element of this.allProgress) {
          if (element.libraryItemId === this.nowPlayingItem.id) {
            element.duration = this.nowPlayingItem.media.duration
            element.currentTime = this.nowTrackStartTime + this.nowPlayedTime
            element.progress = Math.round(element.currentTime / element.duration * 100) / 100
            element.isFinished = element.progress === 1 ? true : false
            upProgress.duration = element.duration
            upProgress.currentTime = element.currentTime
            upProgress.progress = element.progress
            upProgress.isFinished = element.isFinished
            updateSession.currentTime = element.currentTime
            break
          }
        }
        console.log("当前时间", upProgress.currentTime)
        console.log("当前进度", upProgress.progress)
        await updateProgress(this.nowPlayingItem.id, upProgress)
        console.log("会话当前时间", updateSession.currentTime)
        console.log("会话汇报间隔", updateSession.timeListened)
        await syncSession(this.sessionId, updateSession)
        this.itemProgress = this.getProgressById(this.itemTransfer.id)
        this.itemDuration = this.getDuration(this.itemTransfer.id)
        this.syncTime = new Date().getTime() / 1000
        this.elapsedTime = 0
        let tmpItemsInProgress = await getLibrarieItemsInProgress(this.selectedLibraryId)
        if (tmpItemsInProgress.length > 0) {
          this.libraryItemsInProgress = tmpItemsInProgress.sort((a, b) => {
            const progressA = this.allProgress.find(p => p.libraryItemId === a.id);
            const progressB = this.allProgress.find(p => p.libraryItemId === b.id);
            if (progressA && progressB) {
              return progressB.lastUpdate - progressA.lastUpdate;
            }
            return 0;
          });
        }
        let tmpItemsFinished = await getLibrarieItemsFinished(this.selectedLibraryId)
        if (tmpItemsFinished.length > 0) {
          this.libraryItemsFinished = tmpItemsFinished
        }
      }
    })
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      console.info(`播放器跳转成功，当前时间为 ${seekDoneTime}`);
    })
    avPlayer.on('speedDone', (speed: number) => {
      console.info(`播放器设置速度成功，当前速度为 ${speed}`);
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
          break;
        case 'initialized':
          console.info('播放器初始化。');
          avPlayer.prepare();
          break;
        case 'prepared':
          console.info('播放器就绪。');
          this.avPlayer!.setSpeed(this.speed)
          this.setSessionInfo()
          this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PREPARE, this.startTime)
          this.avPlayer!.seek(this.startTime * 1000)
          if (this.isPlayingTransfer === true) {
            this.avPlayer!.play()
          } else {
            this.avPlayer!.pause()
          }
          break;
        case 'playing':
          console.info('播放器开始播放。');
          this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY, this.nowPlayedTime)
          break;
        case 'paused':
          console.info('播放器暂停。');
          this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE, this.nowPlayedTime)
          break;
        case 'completed':
          console.info('播放完毕。');
          await avPlayer.reset();
          if (this.nowPlayingIndex + 1 > this.nowPlayingTracks.length - 1) {
            avPlayer.stop()
          } else {
            this.nowPlayingIndex++
            this.playTitle = this.nowPlayingChapters[this.nowPlayingIndex].title
            avPlayer.url =
              this.server + this.nowPlayingTracks[this.nowPlayingIndex].contentUrl + "?token=" + this.apitoken
            this.startTime = 0
            this.nowTrackStartTime = this.nowPlayingTracks[this.nowPlayingIndex].startOffset
            avPlayer.prepare()
          }
          break;
        case 'stopped':
          console.info('播放器停止。');
          this.sleepTime = 0
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
    this.startTime = playItem.currentTime - playItem.audioTracks[index].startOffset
    console.log("起始位置为", this.startTime * 1000)
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

  async getPlayingBookmarks(itemId: string): Promise<Bookmark[]> {
    let nowPlayingBookmarks: Bookmark[] = []
    this.bookmarks.forEach(element => {
      if (element.libraryItemId === itemId) {
        nowPlayingBookmarks.push(element)
      }
    });
    return nowPlayingBookmarks
  }

  async aboutToAppear() {
    this.mainWindow = await window.getLastWindow(getContext(this))
    this.displayWidth = px2vp(this.mainWindow.getWindowProperties().windowRect.width)
    this.displayHeight = px2vp(this.mainWindow.getWindowProperties().windowRect.height)
    if (this.displayHeight < 700) {
      this.showCover = false
    } else if (this.displayWidth >= 320 && this.displayWidth < 550) {
      this.coverWidth = "80%"
      this.descriptionLine = 5
    } else if (this.displayWidth >= 550 && this.displayWidth < 840) {
      this.coverWidth = "280"
      this.descriptionLine = 3
    } else if (this.displayWidth >= 840) {
      this.coverWidth = "280"
      this.descriptionLine = 3
    }
    this.mainWindow.on('windowSizeChange', (size) => {
      this.displayWidth = px2vp(size.width)
      this.displayHeight = px2vp(size.height)
      if (this.displayHeight < 700) {
        this.showCover = false
      } else if (this.displayWidth >= 320 && this.displayWidth < 550) {
        this.coverWidth = "80%"
        this.descriptionLine = 5
        this.showCover = true
      } else if (this.displayWidth >= 550 && this.displayWidth < 840) {
        this.coverWidth = "280"
        this.descriptionLine = 3
        this.showCover = true
      } else if (this.displayWidth >= 840) {
        this.coverWidth = "280"
        this.descriptionLine = 3
        this.showCover = true
      }
    })
  }

  build() {
    Stack() {
      Column() {
        Image(this.server + `/api/items/${this.itemTransfer.id}/cover?format=jpeg&width=1024` +
          `&token=${this.apitoken}`)
          .alt($rawfile('nocover.jpg'))
          .width(this.coverWidth)
          .aspectRatio(1)
          .borderRadius(10)
          .objectFit(ImageFit.Fill)
          .margin({ top: 20 })
          .visibility(this.showCover === true ? Visibility.Visible : Visibility.None)
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
                if (this.startPlayingTransfer === true) {
                  let currentTime: number = 0
                  for (let element of this.allProgress) {
                    if (element.libraryItemId === this.nowPlayingItem.id) {
                      currentTime = element.currentTime
                      break
                    }
                  }
                  let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
                  let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleFlags)
                  let updateSession: UpdateSession = {
                    deviceInfo: {
                      id: '00000000',
                      userId: this.playItem!.userId,
                      deviceName: deviceInfo.productModel,
                      clientName: 'Abs-HarmonyOS',
                      clientVersion: bundleInfo.versionName
                    },
                    mediaPlayer: "avPlayer",
                    currentTime: currentTime,
                    timeListened: new Date().getTime() / 1000 - this.syncTime
                  }
                  console.log("会话当前时间", updateSession.currentTime)
                  console.log("会话汇报间隔", updateSession.timeListened)
                  await closeSession(this.sessionId, updateSession)
                  await this.session!.destroy()
                  await this.stopContinuousTask();
                }
                this.speed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X
                this.speedNumber = 1
                this.isPlayingTransfer = true
                await this.startContinuousTask();
                await this.avPlayer!.reset()
                this.setAVPlayerCallback(this.avPlayer!);
                this.nowPlayingChapters = await getItem(this.itemTransfer.id)
                this.nowPlayingItem = this.itemTransfer
                this.nowPlayingBookmarks = await this.getPlayingBookmarks(this.nowPlayingItem.id)
                this.playItem = await getPlayItem(this.nowPlayingItem.id)
                let url: string = await this.getPlayContent(this.playItem)
                this.sessionId = this.playItem.id
                this.session = await AVSessionManager.createAVSession(context, 'AUDIO_PLAY', 'audio');
                console.log("创建Session。")
                await this.setSessionCallback()
                await this.session!.activate()
                console.log("Session已激活。")
                this.avPlayer!.url = url
                this.startPlayingTransfer = true
                this.syncTime = new Date().getTime() / 1000
                animateTo({
                  duration: 300,
                  curve: Curve.EaseOut,
                }, () => {
                  this.sidebarShow = false
                })
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
              .onClick(() => {
                animateTo({
                  duration: 300,
                  curve: Curve.EaseOut,
                }, () => {
                  this.sidebarShow = false
                })
                this.showMore = true
              })
            }
            .width('100%')
            .height('auto')

            Column() {
              Text(this.itemProgress === null ?
                `你的进度：${this.getProgressById(this.itemTransfer.id).progress * 100}%` :
                `你的进度：${this.itemProgress!.progress * 100}%`)
                .fontSize(14)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
              Text(this.itemDuration === null ? this.getDuration(this.itemTransfer.id) : this.itemDuration)
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

      Column() {
        Column() {
          Text("标记为已听完")
            .width('100%')
            .height(60)
            .textAlign(TextAlign.Center)
            .border({
              radius: 10
            })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(20)
            .fontColor(Color.White)
            .backgroundColor('#333333')
            .onClick(async () => {
              this.showMore = false
              let upProgress: UpdateProgress = {
                duration: this.itemTransfer.media.duration,
                currentTime: this.itemTransfer.media.duration,
                progress: 1,
                isFinished: true
              }
              await updateProgress(this.itemTransfer.id, upProgress)
              for (let element of this.allProgress) {
                if (element.libraryItemId === this.itemTransfer.id) {
                  element.currentTime = element.duration
                  element.progress = 1
                  element.isFinished = true
                  break
                }
              }
              this.itemProgress = this.getProgressById(this.itemTransfer.id)
              this.itemDuration = this.getDuration(this.itemTransfer.id)
              console.log("标记为已听完。")
              promptAction.showToast({
                message: '标记为已听完',
                duration: 500
              });
              let tmpItemsInProgress = await getLibrarieItemsInProgress(this.selectedLibraryId)
              if (tmpItemsInProgress.length > 0) {
                this.libraryItemsInProgress = tmpItemsInProgress.sort((a, b) => {
                  const progressA = this.allProgress.find(p => p.libraryItemId === a.id);
                  const progressB = this.allProgress.find(p => p.libraryItemId === b.id);
                  if (progressA && progressB) {
                    return progressB.lastUpdate - progressA.lastUpdate;
                  }
                  return 0;
                });
              }
              let tmpItemsFinished = await getLibrarieItemsFinished(this.selectedLibraryId)
              if (tmpItemsFinished.length > 0) {
                this.libraryItemsFinished = tmpItemsFinished
              }
            })
          Text("放弃进度")
            .width('100%')
            .height(60)
            .textAlign(TextAlign.Center)
            .border({
              radius: 10
            })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(20)
            .fontColor(Color.White)
            .backgroundColor('#333333')
            .onClick(async () => {
              this.showMore = false
              let upProgress: UpdateProgress = {
                duration: this.itemTransfer.media.duration,
                currentTime: 0,
                progress: 0,
                isFinished: false
              }
              await updateProgress(this.itemTransfer.id, upProgress)
              for (let element of this.allProgress) {
                if (element.libraryItemId === this.itemTransfer.id) {
                  element.currentTime = 0
                  element.progress = 0
                  element.isFinished = false
                  break
                }
              }
              this.itemProgress = this.getProgressById(this.itemTransfer.id)
              this.itemDuration = this.getDuration(this.itemTransfer.id)
              console.log("放弃进度。")
              promptAction.showToast({
                message: '放弃进度',
                duration: 500
              });
              let tmpItemsInProgress = await getLibrarieItemsInProgress(this.selectedLibraryId)
              if (tmpItemsInProgress.length > 0) {
                this.libraryItemsInProgress = tmpItemsInProgress.sort((a, b) => {
                  const progressA = this.allProgress.find(p => p.libraryItemId === a.id);
                  const progressB = this.allProgress.find(p => p.libraryItemId === b.id);
                  if (progressA && progressB) {
                    return progressB.lastUpdate - progressA.lastUpdate;
                  }
                  return 0;
                });
              }
              let tmpItemsFinished = await getLibrarieItemsFinished(this.selectedLibraryId)
              if (tmpItemsFinished.length > 0) {
                this.libraryItemsFinished = tmpItemsFinished
              }
            })
        }
        .width('80%')
        .height('auto')
        .borderRadius(10)
        .backgroundColor('#333333')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#80000000')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.showMore = false
        animateTo({
          duration: 300,
          curve: Curve.EaseOut,
        }, () => {
          this.sidebarShow = false
        })
      })
      .visibility(this.showMore === true ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}