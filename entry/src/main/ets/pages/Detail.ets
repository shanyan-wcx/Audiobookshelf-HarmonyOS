import { deviceInfo } from '@kit.BasicServicesKit';

@Component
export default struct Detail {
  @State coverWidth: string = "80%"
  @Consume startPlayingTransfer: boolean

  aboutToAppear() {
    if (deviceInfo.deviceType === 'phone') {
      this.coverWidth = "80%"
    } else if (deviceInfo.deviceType === '2in1') {
      this.coverWidth = "320"
    } else if (deviceInfo.deviceType === 'tablet') {
      this.coverWidth = "320"
    }
  }

  build() {
    Column() {
      Image($rawfile('nocover.jpg'))
        .width(this.coverWidth)
        .aspectRatio(1)
        .borderRadius(10)
        .objectFit(ImageFit.Fill)
        .margin({ top: 20 })
      Column() {
        Text("测试标题")
          .fontSize(28)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text("测试副标题测试副标题")
          .fontSize(18)
          .fontColor('#E5ECF2')
          .margin({ top: 5 })
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
            .onClick(() => {
              this.startPlayingTransfer = true
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
            Text("剩余 58 hr 23 min")
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
              Text("测试作者")
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
              Text("测试时长")
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
              Text("测试演播者")
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
              Text("测试流派")
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
            Text("测试年份")
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
            "这是一段测试介绍这是一段测试介绍这是一段测试介绍这是一段测试介绍这是一段测试介绍这是一段测试介绍这是一段测试介绍这是一段测试介绍这是一段测试介绍。")
            .fontSize(14)
            .fontColor(Color.White)
            .width("100%")
            .height('auto')
            .maxLines(5)
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