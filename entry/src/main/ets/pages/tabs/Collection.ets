import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { Book, Series } from '../../api/Interface'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

@Component
export default struct collection {
  @State displayWidth: number = 0
  @State columnsTemplate: string = "1fr"
  @State libraryId: string = ''
  @Consume PageIndexTransfer: number
  @Consume showProgressTransfer: boolean
  @State collections: Series[] = []
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
    if (display.isFoldable() === true) {
      display.on('foldStatusChange', (foldStatus) => {
        this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
        if (this.displayWidth >= 320 && this.displayWidth < 600) {
          this.columnsTemplate = "1fr"
        } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
          this.columnsTemplate = "1fr 1fr"
        } else if (this.displayWidth >= 840) {
          this.columnsTemplate = "1fr 1fr 1fr"
        }
      })
    }
  }

  build() {
    Column() {
      Text("没有收藏")
        .fontColor(Color.White)
        .fontSize(32)
        .margin({ top: 200 })
        .visibility(this.collections.length === 0 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
    .backgroundColor("#333333")
  }
}