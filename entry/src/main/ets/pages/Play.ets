import window from '@ohos.window';
import { LibraryItem, Chapter } from '../api/Interface'

@Component
export default struct Play {
  @State statusBarHeight: number = 0
  @Consume showPlayTransfer: boolean
  @Consume isPlayingTransfer: boolean
  @Consume itemTransfer: LibraryItem
  @Consume nowPlayingChapters: Chapter[]

  private getStatusBarHeight() {
    window.getLastWindow(getContext(this), (error, topWindow) => {
      if (topWindow) {
        let area = topWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.statusBarHeight = px2vp(area.topRect.height)
      }
    });
  }

  aboutToAppear() {
    this.getStatusBarHeight()
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($rawfile('down.png'))
            .width(35)
            .height(35)
        }
        .width(45)
        .height(45)
        .backgroundColor('#00000000')
        .margin({ left: 25 })
        .onClick(() => {
          this.showPlayTransfer = false
        })

        Button({ type: ButtonType.Circle }) {
          Image($rawfile('more.png'))
            .width(35)
            .height(35)
        }
        .width(45)
        .height(45)
        .margin({ right : 10 })
        .backgroundColor('#00000000')
        .onClick(() => {

        })
      }
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)

      Image($rawfile('nocover.jpg'))
        .width("80%")
        .aspectRatio(1)
        .borderRadius(10)
        .objectFit(ImageFit.Fill)
        .margin({ top: 20 })
      Column() {
        Text(this.nowPlayingChapters.length > 0 ? this.nowPlayingChapters[0].title : "")
          .fontSize(28)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(this.itemTransfer.media.metadata.authorName)
          .fontSize(18)
          .fontColor('#E5ECF2')
          .margin({ top: 5 })
      }
      .width("100%")

      Column() {
        Column() {
          Row() {
            Text("05:04")
              .fontSize(16)
              .fontColor(Color.White)
            Text("-02:18")
              .fontSize(16)
              .fontColor(Color.White)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Progress({
            value: 50,
            total: 100,
            type: ProgressType.Linear
          })
            .style({ strokeWidth: 10 })
            .width('100%')
            .margin({ top: 5, bottom: 15 })
            .color(Color.White)
        }
        .width('100%')

        Row() {
          Button({ type: ButtonType.Circle }) {
            Image($rawfile('previous.png'))
              .width(35)
              .height(35)
          }
          .width(45)
          .height(45)
          .backgroundColor('#00000000')
          .onClick(() => {

          })

          Button({ type: ButtonType.Circle }) {
            Image($rawfile('rewind.png'))
              .width(45)
              .height(45)
          }
          .width(60)
          .height(60)
          .margin({ right: 10 })
          .backgroundColor('#00000000')
          .onClick(() => {

          })

          Button({ type: ButtonType.Circle }) {
            Image(this.isPlayingTransfer===true?$rawfile('suspend.png'):$rawfile('play.png'))
              .width(40)
              .height(40)
          }
          .width(70)
          .height(70)
          .backgroundColor('#383838')
          .onClick(() => {
            this.isPlayingTransfer = !this.isPlayingTransfer
          })

          Button({ type: ButtonType.Circle }) {
            Image($rawfile('forward.png'))
              .width(40)
              .height(40)
          }
          .width(55)
          .height(55)
          .margin({ left: 10 })
          .backgroundColor('#00000000')
          .onClick(() => {

          })

          Button({ type: ButtonType.Circle }) {
            Image($rawfile('next.png'))
              .width(35)
              .height(35)
          }
          .width(45)
          .height(45)
          .backgroundColor('#00000000')
          .onClick(() => {

          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Button({ type: ButtonType.Circle }) {
            Image($rawfile('bookmark.png'))
              .width(35)
              .height(35)
          }
          .width(35)
          .height(35)
          .backgroundColor('#00000000')

          Button({ type: ButtonType.Circle }) {
            Image($rawfile('speed.png'))
              .width(35)
              .height(35)
          }
          .width(35)
          .height(35)
          .backgroundColor('#00000000')

          Button({ type: ButtonType.Circle }) {
            Image($rawfile('sleep.png'))
              .width(35)
              .height(35)
          }
          .width(35)
          .height(35)
          .backgroundColor('#00000000')

          Button({ type: ButtonType.Circle }) {
            Image($rawfile('list2.png'))
              .width(35)
              .height(35)
          }
          .width(35)
          .height(35)
          .backgroundColor('#00000000')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('80%')
      .height(240)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor('#232323')
    .padding({ top: this.statusBarHeight })
  }
}