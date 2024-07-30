import { router } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { LibraryItem } from '../../api/Interface'
import { getCover, getLibrarieItems } from '../../api/Api'
import { deviceInfo } from '@kit.BasicServicesKit';

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

@Component
export default struct library {
  @State progressValue: number = 100;
  @State columnsTemplate: string = "1fr 1fr"
  @Consume PageIndexTransfer: number
  libraryId: string = ''
  @State libraryItems: LibraryItem[] = []
  @Consume itemTransfer: LibraryItem
  private books: string[] =
    ['Book 1', 'Book 2', 'Book 3', 'Book 4', 'Book 5', 'Book 6', 'Book 7', 'Book 8',
      'Book 9', 'Book 10', 'Book 11', 'Book 12', 'Book 13'];
  private covers: Resource[] =
    [$rawfile('nocover.jpg'), $rawfile('nocover.jpg'), $rawfile('nocover.jpg'), $rawfile('nocover.jpg'),
      $rawfile('nocover.jpg'), $rawfile('nocover.jpg'), $rawfile('nocover.jpg'), $rawfile('nocover.jpg'),
      $rawfile('nocover.jpg'), $rawfile('nocover.jpg'), $rawfile('nocover.jpg'), $rawfile('nocover.jpg'),
      $rawfile('nocover.jpg')];

  async aboutToAppear() {
    if (deviceInfo.deviceType === 'phone') {
      this.columnsTemplate = "1fr 1fr"
    } else if (deviceInfo.deviceType === '2in1') {
      this.columnsTemplate = "1fr 1fr 1fr"
    } else if (deviceInfo.deviceType === 'tablet') {
      this.columnsTemplate = "1fr 1fr 1fr 1fr 1fr"
    }

    console.log("获取媒体库项目", this.libraryId)
    this.libraryItems = await getLibrarieItems(this.libraryId)

    this.libraryItems.forEach(async (element) => {
      try {
        await getCover(element.id)
      } catch (error) {
        console.error(JSON.stringify(error));
        console.log("获取封面失败。")
      }
    });
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.libraryItems, (item: number, index) => {
          GridItem() {
            Stack({ alignContent: Alignment.Bottom }) {
              Image(filesDir + `/covers/${this.libraryItems[index].id}.webp`)
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
  }
}