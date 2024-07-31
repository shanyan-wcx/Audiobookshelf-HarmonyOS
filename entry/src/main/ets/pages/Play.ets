import window from '@ohos.window';
import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { LibraryItem, Chapter } from '../api/Interface'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

function formatDuration(seconds: number): string {
  const roundedSeconds = Math.round(seconds);

  const hours = Math.floor(roundedSeconds / 3600);
  const minutes = Math.floor((roundedSeconds % 3600) / 60);
  const secs = roundedSeconds % 60;

  const paddedMinutes = minutes.toString().padStart(2, '0');
  const paddedSeconds = secs.toString().padStart(2, '0');

  let formattedTime = `${paddedMinutes}:${paddedSeconds}`;
  if (hours > 0) {
    const paddedHours = hours.toString().padStart(2, '0');
    formattedTime = `${paddedHours}:${formattedTime}`;
  }

  return formattedTime;
}

@Component
export default struct Play {
  @State displayWidth: number = 0
  @State statusBarHeight: number = 0
  @State coverWidth: string = "20%"
  @State showChapters: boolean = false
  @State showMenu: boolean = false
  @Consume showPlayTransfer: boolean
  @Consume isPlayingTransfer: boolean
  @Consume startPlayingTransfer: boolean
  @Consume itemTransfer: LibraryItem
  @Consume nowPlayingChapters: Chapter[]
  @Consume nowPlayingItem: LibraryItem

  @Builder
  bindMenuBuilder() {
    Menu() {
      MenuItem({ content: "关闭播放器" })
        .onClick(() => {
          this.startPlayingTransfer === false
        })
        .width('auto')
        .height('auto')
        .borderRadius(10)
    }
  }

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
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    if (this.displayWidth >= 320 && this.displayWidth < 600) {
      this.coverWidth = "80%"
    } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
      this.coverWidth = "280"
    } else if (this.displayWidth >= 840) {
      this.coverWidth = "240"
    }
  }

  build() {
    Stack() {
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
            setTimeout(() => {
              this.startPlayingTransfer = true
            }, 500);
          })

          Button({ type: ButtonType.Circle }) {
            Image($rawfile('more.png'))
              .width(35)
              .height(35)
          }
          .width(45)
          .height(45)
          .margin({ right: 10 })
          .backgroundColor('#00000000')
          .onClick(() => {
            this.showMenu = true
          })

          // .bindMenu(this.bindMenuBuilder())
        }
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)

        Image(fileUri.getUriFromPath(filesDir + `/covers/${this.itemTransfer.id}.jpg`))
          .alt($rawfile('nocover.jpg'))
          .width(this.coverWidth)
          .aspectRatio(1)
          .borderRadius(10)
          .objectFit(ImageFit.Fill)
          .margin({ top: 20 })
        Column() {
          Text(this.nowPlayingChapters.length > 0 ? this.nowPlayingChapters[0].title : "")
            .fontSize(28)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.nowPlayingItem.media.metadata.authorName)
            .fontSize(18)
            .fontColor('#E5ECF2')
            .margin({ top: 5 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
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
              Image(this.isPlayingTransfer === true ? $rawfile('suspend.png') : $rawfile('play.png'))
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
            .onClick(() => {
              this.showChapters = true
            })
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

      Column() {
        Column() {
          Text("关闭播放器")
            .width('100%')
            .height(60)
            .textAlign(TextAlign.Center)
            .border({
              radius: 10
            })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(24)
            .fontColor(Color.White)
            .backgroundColor('#333333')
            .onClick(() => {
              this.showMenu = false
              this.startPlayingTransfer = false
              this.isPlayingTransfer = false
              this.showPlayTransfer = false
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
        this.showMenu = false
      })
      .visibility(this.showMenu === true ? Visibility.Visible : Visibility.None)

      Column() {
        Column() {
          List() {
            ForEach(this.nowPlayingChapters, (item: number, index) => {
              ListItem() {
                Row() {
                  Text(this.nowPlayingChapters[index].title)
                    .width('100%')
                    .layoutWeight(1)
                    .margin({ left: 15 })
                    .padding({ right: 10 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontSize(16)
                    .fontColor(Color.White)
                  Text(formatDuration(this.nowPlayingChapters[index].start))
                    .width(65)
                    .margin({ right: 15 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontSize(16)
                    .fontColor(Color.Gray)
                    .textAlign(TextAlign.End)
                }
                .width('100%')
                .height(50)
                .justifyContent(FlexAlign.SpaceBetween)
                .backgroundColor('#333333')
                .onClick(() => {
                  this.showChapters = false
                })
              }
            })
          }
          .width('100%')
          .height('100%')
          .borderRadius(10)
          .scrollBar(BarState.Off)
        }
        .width('80%')
        .height('60%')
        .borderRadius(10)
        .backgroundColor('#333333')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#80000000')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.showChapters = false
      })
      .visibility(this.showChapters === true ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}