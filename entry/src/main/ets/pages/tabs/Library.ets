import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { LibraryItem } from '../../api/Interface'
import { getCover, getLibrarieItems } from '../../api/Api'
import Loading from '../Loading'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

@Component
export default struct library {
  @State displayWidth: number = 0
  @State progressValue: number = 100;
  @State columnsTemplate: string = "1fr"
  @Consume PageIndexTransfer: number
  libraryId: string = ''
  @State libraryItems: LibraryItem[] = []
  @Consume itemTransfer: LibraryItem
  @Consume nowPlayingItem: LibraryItem
  @Consume showProgressTransfer: boolean

  async aboutToAppear() {
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    if (this.displayWidth >= 320 && this.displayWidth < 600) {
      this.columnsTemplate = "1fr 1fr"
    } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
      this.columnsTemplate = "1fr 1fr 1fr"
    } else if (this.displayWidth >= 840) {
      this.columnsTemplate = "1fr 1fr 1fr 1fr 1fr"
    }
    this.showProgressTransfer = true
    console.log("获取媒体库项目", this.libraryId)
    this.libraryItems = await getLibrarieItems(this.libraryId)

    await Promise.all(this.libraryItems.map(async (element) => {
      let coverStatus = fs.accessSync(filesDir + `/covers/${element.id}.jpg`)
      if (coverStatus === false) {
        try {
          await getCover(element.id)
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
                  .onClick(() => {
                    this.itemTransfer = this.libraryItems[index]
                    this.PageIndexTransfer = 3
                  })
                Progress({
                  value: this.progressValue,
                  total: 100,
                  type: ProgressType.Linear
                })
                  .size({ width: '100%', height: 'auto' })
                  .style({ strokeWidth: 5 })
                  .color(this.progressValue === 100 ? Color.Green : Color.Orange)
              }
              .width('100%')
              .borderRadius(10)
              .clip(true)
            }
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