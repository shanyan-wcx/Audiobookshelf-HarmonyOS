import { display } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { LibraryItem, Chapter, Progress, PlayItem } from '../api/Interface'
import { getItem, getPlayItem } from '../api/Api'

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
  @Consume nowPlayTime: number
  @Consume allProgress: Progress[]
  @Consume itemTransfer: LibraryItem
  @Consume isPlayingTransfer: boolean
  @Consume nowPlayingItem: LibraryItem
  @Consume nowPlayingChapters: Chapter[]
  @Consume showProgressTransfer: boolean
  @Consume avPlayer: media.AVPlayer | null
  @Consume server: string

  async getPlayContent(playItem: PlayItem): Promise<string> {
    let index: number = 0
    for (let track of playItem.audioTracks) {
      if (track.startOffset > playItem.currentTime) {
        index = track.index - 2
        console.log("找到当前音轨序号为" + index + "，起始位置为" + playItem.audioTracks[index].startOffset)
        break
      }
    }
    let url: string = this.server + playItem.audioTracks[index].contentUrl
    console.log("找到音频Url为", url)
    this.nowPlayTime = playItem.currentTime - playItem.audioTracks[index].startOffset
    console.log("起始位置为", formatDuration(this.nowPlayTime))
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
              this.nowPlayingChapters = await getItem(this.itemTransfer.id)
              this.nowPlayingItem = this.itemTransfer
              let playItem: PlayItem = await getPlayItem(this.nowPlayingItem.id)
              if (this.avPlayer!.state !== 'idle') {
                this.avPlayer!.reset()
              }
              console.log("播放器重置。")
              let url: string = await this.getPlayContent(playItem)
              this.avPlayer!.url = url
              this.avPlayer!.prepare()
              console.log("播放器准备。")
              this.avPlayer!.seek(this.nowPlayTime)
              console.log("播放器跳转到当前位置。")
              this.avPlayer!.play()
              console.log("播放器开始播放。")
              this.startPlayingTransfer = true
              this.isPlayingTransfer = true
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