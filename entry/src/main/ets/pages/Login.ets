import window from '@ohos.window';
import { router, promptAction } from '@kit.ArkUI';
import { getLogin } from '../api/Api'
import { LoginInfo, Config } from '../api/Interface'
import { readConfig, writeConfig } from '../util/fs'

let config: Config = {
  loginInfo: {
    server: '',
    username: '',
    password: ''
  },
  rememberLoginInfo: false
}

class RouTmp {
  firstLogin: boolean = true
}

@Entry
@Component
export default struct login {
  @State apitoken: string | null = null
  @State statusBarHeight: number = 0
  @State showProgress: boolean = false
  private params: RouTmp = router.getParams() as RouTmp
  loginInfo: LoginInfo = {
    server: '',
    username: '',
    password: ''
  }

  async aboutToAppear() {
    this.getStatusBarHeight()
    if (this.params.firstLogin === true) {
      config = readConfig(config)
      if (config.rememberLoginInfo === true) {
        this.loginInfo.server = config.loginInfo.server
        this.loginInfo.username = config.loginInfo.username
        this.loginInfo.password = config.loginInfo.password
        this.apitoken = await getLogin(this.loginInfo)
        if (this.apitoken !== null) {
          console.info("登陆成功！")
          promptAction.showToast({
            message: '登陆成功！',
            duration: 500
          });
          router.replaceUrl({
            url: 'pages/Main',
            params: {
              server: this.loginInfo.server,
              username: this.loginInfo.username,
              apitoken: this.apitoken
            }
          })
        } else {
          console.error("登陆失败！")
          promptAction.showToast({
            message: '登陆失败！',
            duration: 500
          });
        }
      }
    } else {
      config.loginInfo = this.loginInfo
      config.rememberLoginInfo = false
      writeConfig(config)
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

  build() {
    Column() {
      Stack() {
        Column() {
          Image($rawfile('logo.png'))
            .width(60)
            .height(60)
          Row() {
            Text("服务器")
              .width(60)
              .height(40)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            TextInput({
              placeholder: 'https://my.abs.com',
              text: config.loginInfo.server
            })
              .width('70%')
              .height(40)
              .backgroundColor('#60ffffff')
              .caretColor(Color.White)
              .fontColor(Color.White)
              .enterKeyType(EnterKeyType.Next)
              .onChange((value) => {
                this.loginInfo.server = value;
              })
          }
          .width('85%')
          .height('auto')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceEvenly)

          Row() {
            Text("用户名")
              .width(60)
              .height(40)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            TextInput({
              placeholder: 'Username',
              text: config.loginInfo.username
            })
              .width('70%')
              .height(40)
              .backgroundColor('#60ffffff')
              .caretColor(Color.White)
              .fontColor(Color.White)
              .enterKeyType(EnterKeyType.Next)
              .onChange((value) => {
                this.loginInfo.username = value;
              })
          }
          .width('85%')
          .height('auto')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceEvenly)

          Row() {
            Text("密码")
              .width(60)
              .height(40)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            TextInput({
              placeholder: 'Password',
              text: config.loginInfo.password
            })
              .width('70%')
              .height(40)
              .backgroundColor('#60ffffff')
              .caretColor(Color.White)
              .fontColor(Color.White)
              .type(InputType.Password)
              .enterKeyType(EnterKeyType.Next)
              .onChange((value) => {
                this.loginInfo.password = value;
              })
          }
          .width('85%')
          .height('auto')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceEvenly)

          Row() {
            Toggle({ type: ToggleType.Checkbox })
              .width(20)
              .height(20)
              .selectedColor('#60222222')
              .onChange((value) => {
                if (value === true) {
                  config.loginInfo = this.loginInfo
                  config.rememberLoginInfo = true
                } else {
                  config.loginInfo = {
                    server: '',
                    username: '',
                    password: ''
                  }
                  config.rememberLoginInfo = false
                }
              })
            Text("自动登录")
              .width(100)
              .height(20)
              .fontSize(16)
              .fontColor(Color.White)
              .margin({ left: 5 })
          }
          .width('85%')
          .height('auto')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)

          Button("登录")
            .fontSize(18)
            .width(100)
            .height(40)
            .backgroundColor('#aabbcc')
            .onClick(async () => {
              this.showProgress = true
              this.apitoken = await getLogin(this.loginInfo)
              if (this.apitoken !== null) {
                writeConfig(config)
                this.showProgress = false
                console.info("登陆成功！")
                promptAction.showToast({
                  message: '登陆成功！',
                  duration: 500
                });
                router.replaceUrl({
                  url: 'pages/Main',
                  params: {
                    server: this.loginInfo.server,
                    username: this.loginInfo.username,
                    apitoken: this.apitoken
                  }
                })
              } else {
                this.showProgress = false
                console.error("登陆失败！")
                promptAction.showToast({
                  message: '登陆失败！',
                  duration: 500
                });
              }
            })
        }
        .height('45%')
        .width('85%')
        .border({ width: 0, radius: 20, color: Color.White })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ top: 180 })
        .backgroundColor('#111111')

        Column() {
          LoadingProgress()
            .width("100%")
            .height(80)
            .color(Color.White)
        }
        .height('45%')
        .width('85%')
        .border({ width: 0, radius: 20, color: Color.White })
        .margin({ top: 180 })
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#75000000')
        .visibility(this.showProgress === true ? Visibility.Visible : Visibility.None)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#222222')
    .padding({ top: this.statusBarHeight })
  }
}