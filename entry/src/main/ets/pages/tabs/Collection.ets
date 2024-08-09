import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { Series } from '../../api/Interface'

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
  @Consume sidebarShow: boolean
  @Consume mainWindow: window.Window

  async aboutToAppear() {
    this.displayWidth = px2vp(this.mainWindow.getWindowProperties().windowRect.width)
    if (this.displayWidth >= 320 && this.displayWidth < 550) {
      this.columnsTemplate = "1fr"
    } else if (this.displayWidth >= 550 && this.displayWidth < 840) {
      this.columnsTemplate = "1fr 1fr"
    } else if (this.displayWidth >= 840) {
      this.columnsTemplate = "1fr 1fr 1fr"
    }
    this.mainWindow.on('windowSizeChange', (size) => {
      this.displayWidth = px2vp(size.width)
      if (this.displayWidth >= 320 && this.displayWidth < 550) {
        this.columnsTemplate = "1fr"
      } else if (this.displayWidth >= 550 && this.displayWidth < 840) {
        this.columnsTemplate = "1fr 1fr"
      } else if (this.displayWidth >= 840) {
        this.columnsTemplate = "1fr 1fr 1fr"
      }
    })
  }

  build() {
    Column() {
      Text("没有收藏")
        .fontColor(Color.White)
        .fontSize(32)
        .margin({ top: 200 })
        .visibility(this.collections.length === 0 && this.showProgressTransfer === false ? Visibility.Visible :
        Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}