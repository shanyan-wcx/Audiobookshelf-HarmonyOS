@Component
export default struct Setting {
  @Consume jumpTime: number

  aboutToAppear() {
  }

  build() {
    Column() {
      Row() {
        Text("跳转时间30秒（默认10秒）")
          .fontColor(Color.White)
          .fontSize(20)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Toggle({ type: ToggleType.Switch, isOn: this.jumpTime === 30 ? true : false })
          .selectedColor(Color.Gray)
          .switchPointColor('#232323')
          .onChange((isOn) => {
            if (isOn === true) {
              this.jumpTime = 30
            } else {
              this.jumpTime = 10
            }
          })
      }
      .width(300)
      .margin({ top: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }
}
