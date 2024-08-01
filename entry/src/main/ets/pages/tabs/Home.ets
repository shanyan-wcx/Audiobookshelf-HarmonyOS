import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { LibraryItem, Progress } from '../../api/Interface'
import { getCover, getLibrarieItemsFinished, getLibrarieItemsInProgress, getProgress } from '../../api/Api'
import Loading from '../Loading'
import { JSON } from '@kit.ArkTS';

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

@Component
export default struct home {
  @State displayWidth: number = 0
  @State coverWidth: number = 100
  @Consume PageIndexTransfer: number
  @State libraryId: string = ''
  @State libraryItemsInProgress: LibraryItem[] = []
  @State libraryItemsFinished: LibraryItem[] = []
  @Consume nowPlayTime: number
  @Consume itemTransfer: LibraryItem
  @Consume nowPlayingItem: LibraryItem
  @Consume showProgressTransfer: boolean
  @Consume allProgress: Progress[]

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

  async aboutToAppear() {
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    if (this.displayWidth >= 320 && this.displayWidth < 600) {
      this.coverWidth = 180
    } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
      this.coverWidth = 280
    } else if (this.displayWidth >= 840) {
      this.coverWidth = 320
    }
    this.showProgressTransfer = true
    this.allProgress = []
    console.log("获取媒体库项目", this.libraryId)
    this.libraryItemsInProgress = await getLibrarieItemsInProgress(this.libraryId)
    await Promise.all(this.libraryItemsInProgress.map(async (element) => {
      let coverStatus = fs.accessSync(filesDir + `/covers/${element.id}.jpg`)
      if (coverStatus === false) {
        try {
          await getCover(element.id)
          let progress = await getProgress(element.id)
          this.allProgress.push(progress)
        } catch (error) {
          console.error(JSON.stringify(error));
          console.log("获取封面失败。")
        }
      }
    }));
    this.libraryItemsFinished = await getLibrarieItemsFinished(this.libraryId)
    await Promise.all(this.libraryItemsFinished.map(async (element) => {
      let coverStatus = fs.accessSync(filesDir + `/covers/${element.id}.jpg`)
      if (coverStatus === false) {
        try {
          await getCover(element.id)
          let progress = await getProgress(element.id)
          this.allProgress.push(progress)
        } catch (error) {
          console.error(JSON.stringify(error));
          console.log("获取封面失败。")
        }
      }
    }));
    this.showProgressTransfer = false
  }

  build() {
    Stack() {
      Column() {
        Column() {
          List() {
            ForEach(this.libraryItemsInProgress, (item: number, index) => {
              ListItem() {
                Stack({ alignContent: Alignment.Bottom }) {
                  Image(this.showProgressTransfer === false ?
                  fileUri.getUriFromPath(filesDir + `/covers/${this.libraryItemsInProgress[index].id}.jpg`) :
                  $rawfile('nocover.jpg'))
                    .alt($rawfile('nocover.jpg'))
                    .width('100%')
                    .aspectRatio(1)
                    .borderRadius(10)
                    .objectFit(ImageFit.Fill)
                    .onClick(async () => {
                      this.itemTransfer = this.libraryItemsInProgress[index]
                      this.PageIndexTransfer = 3
                    })
                  Progress({
                    value: this.getProgressById(this.libraryItemsInProgress[index].id).progress * 100,
                    total: 100,
                    type: ProgressType.Linear
                  })
                    .size({ width: '100%', height: 'auto' })
                    .style({ strokeWidth: 5 })
                    .color(this.getProgressById(this.libraryItemsInProgress[index].id).progress * 100 === 100 ? Color.Green :
                    Color.Orange)
                }
                .width('100%')
                .height('100%')
                .borderRadius(10)
                .clip(true)
              }
              .width(this.coverWidth)
              .height(this.coverWidth)
              .borderRadius(10)
              .padding({ left: 20 })
            })
          }
          .listDirection(Axis.Horizontal)
          .width('100%')
          .height(this.coverWidth)
          .scrollBar(BarState.Off)

          Column() {
            Text("继续收听")
              .fontColor('#F2E4C1')
              .fontSize(16)
              .backgroundColor(Color.Black)
              .width(100)
              .height(23)
              .margin({ left: 20 })
              .textAlign(TextAlign.Center)
              .border({
                width: 2,
                color: '#9E9681'
              })
          }
          .width('100%')
          .height(25)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#674625')
          .shadow({
            offsetX: 0,
            offsetY: 20,
            radius: 20,
            color: '#95000000'
          })
        }
        .width('100%')
        .height(this.coverWidth + 45)
        .justifyContent(FlexAlign.End)

        Column() {
          List() {
            ForEach(this.libraryItemsFinished, (item: number, index) => {
              ListItem() {
                Stack({ alignContent: Alignment.Bottom }) {
                  Image(this.showProgressTransfer === false ?
                  fileUri.getUriFromPath(filesDir + `/covers/${this.libraryItemsFinished[index].id}.jpg`) :
                  $rawfile('nocover.jpg'))
                    .alt($rawfile('nocover.jpg'))
                    .width('100%')
                    .aspectRatio(1)
                    .borderRadius(10)
                    .objectFit(ImageFit.Fill)
                    .onClick(async () => {
                      this.itemTransfer = this.libraryItemsFinished[index]
                      this.PageIndexTransfer = 3
                    })
                  Progress({
                    value: this.getProgressById(this.libraryItemsFinished[index].id).progress * 100,
                    total: 100,
                    type: ProgressType.Linear
                  })
                    .size({ width: '100%', height: 'auto' })
                    .style({ strokeWidth: 5 })
                    .color(this.getProgressById(this.libraryItemsFinished[index].id).progress * 100 === 100 ? Color.Green :
                    Color.Orange)
                }
                .width('100%')
                .height('100%')
                .borderRadius(10)
                .clip(true)
              }
              .width(this.coverWidth)
              .height(this.coverWidth)
              .borderRadius(10)
              .padding({ left: 20 })
            })
          }
          .listDirection(Axis.Horizontal)
          .width('100%')
          .height(this.coverWidth)
          .scrollBar(BarState.Off)

          Column() {
            Text("再次收听")
              .fontColor('#F2E4C1')
              .fontSize(16)
              .backgroundColor(Color.Black)
              .width(100)
              .height(23)
              .margin({ left: 20 })
              .textAlign(TextAlign.Center)
              .border({
                width: 2,
                color: '#9E9681'
              })
          }
          .width('100%')
          .height(25)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#674625')
          .shadow({
            offsetX: 0,
            offsetY: 20,
            radius: 20,
            color: '#95000000'
          })
        }
        .width('100%')
        .height(this.coverWidth + 45)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')

      Column() {
        Loading()
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}