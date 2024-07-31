import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { LibraryItem, Chapter } from '../api/Interface'
import { getItem } from '../api/Api'

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
  @Consume itemTransfer: LibraryItem
  @Consume isPlayingTransfer: boolean
  @Consume nowPlayingItem: LibraryItem
  @Consume nowPlayingChapters: Chapter[]

  aboutToAppear() {
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    if (this.displayWidth >= 320 && this.displayWidth < 600) {
      this.coverWidth = "80%"
      this.descriptionLine = 5
    } else if (this.displayWidth >= 600 && this.displayWidth < 840) {
      this.coverWidth = "280"
      this.descriptionLine = 4
    } else if (this.displayWidth >= 840) {
      this.coverWidth = "240"
      this.descriptionLine = 3
    }
  }

  build() {
    Column() {
      Image(fileUri.getUriFromPath(filesDir + `/covers/${this.itemTransfer.id}.jpg`))
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
              this.startPlayingTransfer = true
              this.isPlayingTransfer = true
              this.nowPlayingItem = this.itemTransfer
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
            Text("你的进度：53%")
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Text("剩余 " + formatDuration(this.itemTransfer.media.duration))
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
              Text(this.itemTransfer.media.duration.toString())
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