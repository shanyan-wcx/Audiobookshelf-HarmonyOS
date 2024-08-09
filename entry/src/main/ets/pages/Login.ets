import { window } from '@kit.ArkUI';
import { router, promptAction } from '@kit.ArkUI';
import { getLogin } from '../api/Api'
import { LoginInfo, Config } from '../api/Interface'
import { readConfig, writeConfig } from '../util/fs'
import { common, Want } from '@kit.AbilityKit';

PersistentStorage.persistProp('confirmPrivacy', false);
let context = getContext(this) as common.UIAbilityContext;

let config: Config = {
  loginInfo: {
    server: '',
    username: '',
    password: ''
  },
  autoLogin: false,
  jumpTime: 10
}

class RouTmp {
  firstLogin: boolean = true
}

@Entry
@Component
export default struct login {
  @State confirm: boolean = false
  @State displayWidth: number = 0
  @State loginHeight: string = '45%'
  @State loginWidth: string = '85%'
  @State loginTop: string = '20%'
  @State apitoken: string = ''
  @State userId: string = ''
  @State statusBarHeight: number = 0
  @State showProgress: boolean = false
  @State mainWindow: window.Window | null = null
  private params: RouTmp = router.getParams() as RouTmp
  loginInfo: LoginInfo = {
    server: '',
    username: '',
    password: ''
  }
  @StorageLink('confirmPrivacy') confirmPrivacy: boolean = false

  async aboutToAppear() {
    if (this.confirmPrivacy === false) {
      console.log('首次启动')
    }
    this.mainWindow = await window.getLastWindow(getContext(this))
    this.getStatusBarHeight()
    this.displayWidth = px2vp(this.mainWindow.getWindowProperties().windowRect.width)
    if (this.displayWidth >= 320 && this.displayWidth < 550) {
      this.loginHeight = '45%'
      this.loginWidth = '85%'
      this.loginTop = '45%'
    } else if (this.displayWidth >= 550 && this.displayWidth < 840) {
      this.loginHeight = '50%'
      this.loginWidth = '60%'
      this.loginTop = '20%'
    } else if (this.displayWidth >= 840) {
      this.loginHeight = '60%'
      this.loginWidth = '40%'
      this.loginTop = '10%'
    }
    this.mainWindow.on('windowSizeChange', (size) => {
      this.displayWidth = px2vp(size.width)
      if (this.displayWidth >= 320 && this.displayWidth < 550) {
        this.loginHeight = '45%'
        this.loginWidth = '85%'
        this.loginTop = '45%'
      } else if (this.displayWidth >= 550 && this.displayWidth < 840) {
        this.loginHeight = '50%'
        this.loginWidth = '60%'
        this.loginTop = '20%'
      } else if (this.displayWidth >= 840) {
        this.loginHeight = '60%'
        this.loginWidth = '40%'
        this.loginTop = '10%'
      }
    })
    if (this.params.firstLogin === true) {
      config = readConfig()
      if (config.autoLogin === true) {
        this.showProgress = true
        this.loginInfo.server = config.loginInfo.server
        this.loginInfo.username = config.loginInfo.username
        this.loginInfo.password = config.loginInfo.password
        let info = await getLogin(this.loginInfo)
        if (info !== null) {
          this.apitoken = info[0]
          this.userId = info[1]
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
              apitoken: this.apitoken,
              userId: this.userId
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
      }
    } else {
      config.loginInfo = this.loginInfo
      config.autoLogin = false
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
            .type(InputType.URL)
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
            .type(InputType.USER_NAME)
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
                config.autoLogin = true
              } else {
                config.loginInfo = {
                  server: '',
                  username: '',
                  password: ''
                }
                config.autoLogin = false
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

        Row() {
          Toggle({ type: ToggleType.Checkbox })
            .width(20)
            .height(20)
            .selectedColor('#60222222')
            .onChange((value) => {
              if (value === true) {
                this.confirm = true
              } else {
                this.confirm = false
              }
            })
          Text("同意隐私政策")
            .width(100)
            .height(20)
            .fontSize(16)
            .fontColor(Color.White)
            .margin({ left: 5 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .decoration({ type: TextDecorationType.Underline, color: Color.White })
            .onClick(() => {
              let want: Want = {
                action: 'ohos.want.action.viewData',
                entities: ['entity.system.browsable'],
                uri: 'https://privacy.shanyan.work'
              };
              context.startAbility(want)
            })
        }
        .width('85%')
        .height('auto')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .visibility(this.confirmPrivacy === false ? Visibility.Visible : Visibility.None)

        Button("登录")
          .fontSize(18)
          .width(100)
          .height(40)
          .backgroundColor('#aabbcc')
          .onClick(async () => {
            if (this.confirm === false && this.confirmPrivacy === false) {
              promptAction.showToast({
                message: '请阅读并同意隐私政策！',
                duration: 500
              });
            } else {
              this.showProgress = true
              let info = await getLogin(this.loginInfo)
              if (info !== null) {
                this.apitoken = info[0]
                this.userId = info[1]
                writeConfig(config)
                this.showProgress = false
                console.info("登陆成功！")
                promptAction.showToast({
                  message: '登陆成功！',
                  duration: 500
                });
                this.confirmPrivacy = true
                router.replaceUrl({
                  url: 'pages/Main',
                  params: {
                    server: this.loginInfo.server,
                    username: this.loginInfo.username,
                    apitoken: this.apitoken,
                    userId: this.userId
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
            }
          })
      }
      .height(this.loginHeight)
      .width(this.loginWidth)
      .border({ width: 0, radius: 20, color: Color.White })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: this.loginTop })
      .backgroundColor('#111111')

      Column() {
        LoadingProgress()
          .width("100%")
          .height(80)
          .color(Color.White)
      }
      .height(this.loginHeight)
      .width(this.loginWidth)
      .border({ width: 0, radius: 20, color: Color.White })
      .margin({ top: this.loginTop })
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#75000000')
      .visibility(this.showProgress === true ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#222222')
    .alignContent(Alignment.Top)
    .padding({ top: this.statusBarHeight })
  }
}