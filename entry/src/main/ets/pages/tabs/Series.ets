import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { Book, Series } from '../../api/Interface'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

@Component
export default struct series {
  @State displayWidth: number = 0
  @State columnsTemplate: string = "1fr"
  @State libraryId: string = ''
  @State imageWidth: number = 0
  @State imageHeight: number = 0
  @Consume PageIndexTransfer: number
  @Consume series: Series[]
  @Consume showProgressTransfer: boolean
  @Consume seriesTransfer: Series
  @Consume backPageIndex: number

  async aboutToAppear() {
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    if (this.displayWidth >= 320 && this.displayWidth < 600) {
      this.columnsTemplate = "1fr"
    } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
      this.columnsTemplate = "1fr 1fr"
    } else if (this.displayWidth >= 840) {
      this.columnsTemplate = "1fr 1fr 1fr"
    }
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.series, (item: number, index) => {
          GridItem() {
            Stack({ alignContent: Alignment.Bottom }) {
              ForEach(this.series[index].books.reverse(), (item: Book, index2) => {
                Image(this.showProgressTransfer === false ?
                fileUri.getUriFromPath(filesDir + `/covers/${item.id}.jpg`) :
                $rawfile('nocover.jpg'))
                  .alt($rawfile('nocover.jpg'))
                  .height('100%')
                  .aspectRatio(1)
                  .clip(true)
                  .objectFit(ImageFit.Fill)
                  .onAreaChange((oldValue: Area, newValue: Area) => {
                    this.imageWidth = new Number(newValue.width).valueOf()
                    this.imageHeight = new Number(newValue.height).valueOf()
                  })
                  .position({ right: index2 * (this.imageWidth / (this.series[index].books.length - 1)) })
                  .shadow({
                    offsetX: 10,
                    offsetY: 0,
                    radius: 10,
                    color: '#95000000'
                  })
              })
              Column() {
                Text(this.series[index].name)
                  .fontColor('#F2E4C1')
                  .fontSize(16)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .height(25)
              .backgroundColor('#95000000')
              .justifyContent(FlexAlign.SpaceAround)
            }
            .width('100%')
            .height('100%')
            .borderRadius(10)
            .clip(true)
          }
          .aspectRatio(2)
          .borderRadius(10)
          .backgroundColor("#cccccc")
          .onClick(async () => {
            this.seriesTransfer = this.series[index]
            this.backPageIndex = 0
            this.PageIndexTransfer = 4
          })
        })
      }
      .columnsTemplate(this.columnsTemplate)
      .columnsGap(20)
      .rowsGap(20)
      .margin({ left: 15, right: 15 })
      .padding({ top: 20, bottom: 20 })
      .height('100%')
      .scrollBar(BarState.Off)
      .visibility(this.series.length !== 0 ? Visibility.Visible : Visibility.None)

      Text("没有系列")
        .fontColor(Color.White)
        .fontSize(32)
        .margin({ top: 200 })
        .visibility(this.series.length === 0 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($rawfile('background.jpg'))
    .backgroundImageSize(ImageSize.Cover)
  }
}