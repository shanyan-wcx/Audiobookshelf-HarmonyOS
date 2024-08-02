import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { LibraryItem, Progress } from '../../api/Interface'
import Loading from '../Loading'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

@Component
export default struct library {
  @State displayWidth: number = 0
  @State columnsTemplate: string = "1fr"
  @Consume PageIndexTransfer: number
  @State libraryId: string = ''
  @Consume libraryItems: LibraryItem[]
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
      this.columnsTemplate = "1fr 1fr"
    } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
      this.columnsTemplate = "1fr 1fr 1fr"
    } else if (this.displayWidth >= 840) {
      this.columnsTemplate = "1fr 1fr 1fr 1fr 1fr"
    }
  }

  build() {
    Stack() {
      Column() {
        Grid() {
          ForEach(this.libraryItems, (item: number, index) => {
            GridItem() {
              Stack({ alignContent: Alignment.Bottom }) {
                Image(this.showProgressTransfer === false ?
                fileUri.getUriFromPath(filesDir + `/covers/${this.libraryItems[index].id}.jpg`) :
                $rawfile('nocover.jpg'))
                  .alt($rawfile('nocover.jpg'))
                  .width('100%')
                  .aspectRatio(1)
                  .borderRadius(10)
                  .objectFit(ImageFit.Fill)
                  .onClick(async () => {
                    this.itemTransfer = this.libraryItems[index]
                    this.PageIndexTransfer = 3
                  })
                Progress({
                  value: this.getProgressById(this.libraryItems[index].id).progress * 100,
                  total: 100,
                  type: ProgressType.Linear
                })
                  .size({ width: '100%', height: 'auto' })
                  .style({ strokeWidth: 5 })
                  .color(this.getProgressById(this.libraryItems[index].id).progress * 100 === 100 ? Color.Green :
                  Color.Orange)
              }
              .width('100%')
              .borderRadius(10)
              .clip(true)
            }
            .borderRadius(10)
          })
        }
        .columnsTemplate(this.columnsTemplate)
        .columnsGap(20)
        .rowsGap(20)
        .margin({ left: 15, right: 15 })
        .padding({ top: 20, bottom: 20 })
        .height('100%')
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundImage($rawfile('background.jpg'))
      .backgroundImageSize(ImageSize.Cover)

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