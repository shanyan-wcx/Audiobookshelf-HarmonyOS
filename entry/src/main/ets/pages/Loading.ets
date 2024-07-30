@Component
export default struct Loading {
  @Consume showProgressTransfer: boolean

  build() {
    Column() {
      LoadingProgress()
        .width("100%")
        .height(80)
        .color(Color.White)
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .visibility(this.showProgressTransfer === true ? Visibility.Visible : Visibility.None)
  }
}

