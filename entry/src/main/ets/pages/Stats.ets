import { LibraryItem, ListeningStats } from '../api/Interface';

@Component
export default struct Stats {
  @Consume listeningStats: ListeningStats
  @Consume libraryItemsFinished: LibraryItem[]

  aboutToAppear() {
  }

  build() {
    Column() {
      Text("你的统计数据")
        .fontColor(Color.White)
        .fontSize(24)
        .margin({ top: 20 })
        .width('100%')
        .textAlign(TextAlign.Start)
      Row() {
        Column() {
          Text(this.libraryItemsFinished.length.toString())
            .fontColor(Color.White)
            .fontSize(48)
          Text("已完成的项目")
            .fontColor(Color.Gray)
            .fontSize(16)
        }

        Column() {
          Text(Object.keys(this.listeningStats.days).length.toString())
            .fontColor(Color.White)
            .fontSize(48)
          Text("收听天数")
            .fontColor(Color.Gray)
            .fontSize(16)
        }

        Column() {
          Text(Math.round(this.listeningStats.totalTime / 60).toString())
            .fontColor(Color.White)
            .fontSize(48)
          Text("收听分钟数")
            .fontColor(Color.Gray)
            .fontSize(16)
        }
      }
      .width('100%')
      .margin({ top: 20 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          Text("每周收听")
            .fontColor(Color.White)
            .fontSize(16)
          Text('80')
            .fontColor(Color.White)
            .fontSize(48)
          Text("分钟")
            .fontColor(Color.White)
            .fontSize(16)
        }

        Column() {
          Text("每日平均值")
            .fontColor(Color.White)
            .fontSize(16)
          Text('11')
            .fontColor(Color.White)
            .fontSize(48)
          Text("分钟")
            .fontColor(Color.White)
            .fontSize(16)
        }

        Column() {
          Text("最好的一天")
            .fontColor(Color.White)
            .fontSize(16)
          Text('45')
            .fontColor(Color.White)
            .fontSize(48)
          Text("分钟")
            .fontColor(Color.White)
            .fontSize(16)
        }

        Column() {
          Text("天")
            .fontColor(Color.White)
            .fontSize(16)
          Text('3')
            .fontColor(Color.White)
            .fontSize(48)
          Text("在一行")
            .fontColor(Color.White)
            .fontSize(16)
        }
      }
      .width('100%')
      .margin({ top: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding({ left: 20, right: 20 })
    .width('100%')
    .height('100%')
  }
}
