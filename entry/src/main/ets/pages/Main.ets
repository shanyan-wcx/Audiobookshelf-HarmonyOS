import window from '@ohos.window';
import { media } from '@kit.MediaKit';
import { router, promptAction, display, curves } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import {
  getLogout,
  getLibraries,
  getLibrarieItems,
  getCover,
  getProgress,
  getLibrarieItemsInProgress,
  getLibrarieItemsFinished
} from '../api/Api'
import { Library, LibraryItem, Chapter, Progress, Track } from '../api/Interface'
import library from './tabs/Library'
import home from './tabs/Home'
import Detail from './Detail'
import Play from './Play'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

let libraries: Library[] = []

class RouTmp {
  server: string = ''
  username: string = ''
  apitoken: string | null = null
}

@Entry
@Component
export default struct main {
  @State statusBarHeight: number = 0;
  @State index: number = 0;
  @State pageIndex: number = 0;
  @Provide @Watch('changePage') PageIndexTransfer: number = this.pageIndex
  @State sidebarShow: boolean = false;
  @Provide @Watch('changePage') showProgressTransfer: boolean = false
  @State selectedLibrary: string = '';
  @State selectedLibraryId: string = '';
  @State selectedLibraryIndex: number = 0;
  @State shadowRadius: number = 0;
  @State isPlaying: boolean = true
  @Provide avPlayer: media.AVPlayer | null = null
  @Provide @Watch('changePage') isPlayingTransfer: boolean = this.isPlaying
  @State startPlaying: boolean = false
  @State showPlay: boolean = false;
  @Provide @Watch('changePage') showPlayTransfer: boolean = this.showPlay;
  @Provide @Watch('changePage') startPlayingTransfer: boolean = this.startPlaying
  @Provide libraryItems: LibraryItem[] = []
  private controller: TabsController = new TabsController();
  private params: RouTmp = router.getParams() as RouTmp
  @Provide pageStack: NavPathStack = new NavPathStack()
  @Provide allProgress: Progress[] = []
  @Provide server: string = this.params.server
  @Provide playTitle: string = ''
  @Provide nowPlayingTracks: Track[] = []
  @Provide nowPlayingIndex: number = 0
  @Provide nowPlayingDuration: number = 0
  @Provide nowPlayedTime: number = 0
  @Provide nowPlayedProgress: number = 0
  @Provide nowTrackStartTime: number = 0
  @Provide libraryItemsInProgress: LibraryItem[] = []
  @Provide libraryItemsFinished: LibraryItem[] = []
  @Provide apitoken: string | null = this.params.apitoken
  @State currentItem: LibraryItem = {
    id: '',
    ino: '',
    oldLibraryItemId: '',
    libraryId: '',
    folderId: '',
    path: '',
    relPath: '',
    isFile: false,
    mtimeMs: 0,
    ctimeMs: 0,
    birthtimeMs: 0,
    addedAt: 0,
    updatedAt: 0,
    isMissing: false,
    isInvalid: false,
    mediaType: '',
    media: {
      id: '',
      libraryItemId: '',
      metadata: {
        title: '',
        titleIgnorePrefix: '',
        subtitle: null,
        authorName: '',
        authorNameLF: '',
        narratorName: '',
        seriesName: '',
        genres: [],
        publishedYear: '',
        publishedDate: null,
        publisher: null,
        description: '',
        isbn: null,
        asin: null,
        language: '',
        explicit: false,
        abridged: false,
      },
      coverPath: '',
      tags: [],
      audioFiles: [],
      chapters: [],
      duration: 0,
      size: 0,
      tracks: [],
      ebookFile: null
    },
    numFiles: 0,
    size: 0
  }
  @Provide @Watch('changePage') itemTransfer: LibraryItem = this.currentItem
  @Provide nowPlayingItem: LibraryItem = this.currentItem
  @Provide nowPlayingChapters: Chapter[] = []

  async changePage() {
    if (this.PageIndexTransfer === 3) {
      this.pageIndex = 3
    }
    this.startPlaying = this.startPlayingTransfer
    this.showPlay = this.showPlayTransfer
    this.isPlaying = this.isPlayingTransfer
    this.currentItem = this.itemTransfer
  }

  @Builder
  bindContentCoverBuilder() {
    Column() {
      Play()
    }
    .transition(TransitionEffect.translate({ y: 1000 }).animation({ curve: curves.springMotion(0.4, 1) }))
  }

  @Builder
  bindMenuBuilder(libraries: Library[]) {
    Menu() {
      ForEach(libraries, (item: number, index) => {
        MenuItem({ content: libraries[index].name })
          .onClick(async () => {
            if (this.selectedLibrary !== libraries[index].name) {
              this.selectedLibrary = libraries[index].name
              this.selectedLibraryId = libraries[index].id
              this.selectedLibraryIndex = index
              this.pageIndex = 0
              this.PageIndexTransfer = 0
              this.showProgressTransfer = true
              this.allProgress = []
              console.log("获取媒体库项目", this.selectedLibraryId)
              this.libraryItems = await getLibrarieItems(this.selectedLibraryId)
              await Promise.all(this.libraryItems.map(async (element) => {
                let coverStatus = fs.accessSync(filesDir + `/covers/${element.id}.jpg`)
                if (coverStatus === false) {
                  try {
                    await getCover(element.id)
                    this.allProgress.push(await getProgress(element.id))
                  } catch (error) {
                    console.error(JSON.stringify(error));
                    console.log("获取封面失败。")
                  }
                }
              }));
              this.showProgressTransfer = false
            }
          })
          .width('auto')
          .height('auto')
          .borderRadius(10)
      })
    }
    .radius(10)
  }

  @Builder
  titlebar() {
    Row() {
      Row() {
        Image($rawfile('logo.png'))
          .width(40)
          .height(40)
          .margin({ left: 15 })
          .visibility(this.pageIndex === 3 ? Visibility.None : Visibility.Visible)
        Button({ type: ButtonType.Normal }) {
          Image($rawfile('return.png'))
            .height(32)
            .width(32)
        }
        .borderRadius(5)
        .width(40)
        .height(40)
        .margin({ left: 15 })
        .backgroundColor('#00000000')
        .visibility(this.pageIndex === 3 ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.pageIndex = 0
          this.PageIndexTransfer = 0
        })

        Text(this.selectedLibrary)
          .width('auto')
          .height(32)
          .fontSize(16)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .margin({ left: 10 })
          .padding({ left: 10, right: 10 })
          .fontColor(Color.White)
          .borderRadius(5)
          .backgroundColor('#30cccccc')
          .bindMenu(this.bindMenuBuilder(libraries))
      }
      .alignItems(VerticalAlign.Center)
      .height(40)

      Row() {
        TextInput({
          placeholder: "搜索 ..."
        })
          .enterKeyType(EnterKeyType.Search)
          .caretColor('#95ffffff')
          .width('40%')
          .height(32)
          .margin({ right: 55 })
          .backgroundColor('#30cccccc')
          .fontColor('#95ffffff')
          .placeholderColor('#60ffffff')
          .onSubmit((value) => {

          })
      }
      .alignItems(VerticalAlign.Center)
      .height(40)
    }
    .width("100%")
    .height('100%')
    .backgroundColor('#232323')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 5, bottom: 10 })
  }

  @Builder
  TabBuilder(title: string, index: number, icon: Resource) {
    if (this.index === index) {
      Column() {
        Text(title)
          .fontSize(16)
          .width('100%')
          .height('100%')
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#232323')
      .onClick(() => {
        this.index = index;
        this.controller.changeIndex(index);
      })
    } else {
      Column() {
        Image(icon)
          .width(20)
          .height(20)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#2F3130')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.index = index;
        this.controller.changeIndex(index);
      })
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

  async aboutToAppear() {
    this.getStatusBarHeight()
    this.showProgressTransfer = true
    libraries = await getLibraries()
    this.selectedLibrary = libraries[0].name
    this.selectedLibraryId = libraries[0].id
    this.avPlayer = await media.createAVPlayer();

    this.allProgress = []
    console.log("获取媒体库项目", this.selectedLibraryId)
    this.libraryItems = await getLibrarieItems(this.selectedLibraryId)
    this.libraryItemsInProgress = await getLibrarieItemsInProgress(this.selectedLibraryId)
    this.libraryItemsFinished = await getLibrarieItemsFinished(this.selectedLibraryId)
    await Promise.all(this.libraryItems.map(async (element) => {
      let coverStatus = fs.accessSync(filesDir + `/covers/${element.id}.jpg`)
      if (coverStatus === false) {
        try {
          await getCover(element.id)
          let progress = await getProgress(element.id)
          this.allProgress.push(progress)
        } catch (error) {
          console.error(JSON.stringify(error));
          console.log("获取封面失败。")
        }
      }
    }));
    this.showProgressTransfer = false
  }

  build() {
    SideBarContainer(SideBarContainerType.Overlay) {
      Column() {
        Text("欢迎，" + this.params.username)
          .width("100%")
          .height(40)
          .fontSize(20)
          .textAlign(TextAlign.Start)
          .fontColor(Color.White)
          .margin({ left: 35, top: this.statusBarHeight + 7 })
        Row() {
          Image($rawfile("tabs/home.png"))
            .width(20)
            .height(20)
            .margin({ left: 20 })
          Text("首页")
            .width("auto")
            .height("30")
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .fontColor(Color.White)
            .margin({ left: 15 })
        }
        .width("100%")
        .height(60)
        .margin({ top: 15 })
        .backgroundColor(this.pageIndex === 0 ? '#4F5052' : '#00000000')
        .onClick(() => {
          this.pageIndex = 0
          this.PageIndexTransfer = 0
          this.sidebarShow = false
        })

        Row() {
          Image($rawfile("tabs/home.png"))
            .width(20)
            .height(20)
            .margin({ left: 20 })
          Text("用户信息统计")
            .width("auto")
            .height("30")
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .fontColor(Color.White)
            .margin({ left: 15 })
        }
        .width("100%")
        .height(60)
        .backgroundColor(this.pageIndex === 1 ? '#4F5052' : '#00000000')
        .onClick(() => {
          this.pageIndex = 1
          this.PageIndexTransfer = 1
          this.sidebarShow = false
        })

        Row() {
          Image($rawfile("tabs/home.png"))
            .width(20)
            .height(20)
            .margin({ left: 20 })
          Text("设置")
            .width("auto")
            .height("30")
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .fontColor(Color.White)
            .margin({ left: 15 })
        }
        .width("100%")
        .height(60)
        .backgroundColor(this.pageIndex === 2 ? '#4F5052' : '#00000000')
        .onClick(() => {
          this.pageIndex = 2
          this.PageIndexTransfer = 2
          this.sidebarShow = false
        })

        Row() {
          Image($rawfile("tabs/home.png"))
            .width(20)
            .height(20)
            .margin({ left: 20 })
          Text("切换服务器/用户")
            .width("auto")
            .height("30")
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .fontColor(Color.White)
            .margin({ left: 15 })
        }
        .width("100%")
        .height(60)
        .onClick(async () => {
          this.sidebarShow = false
          await getLogout()
          promptAction.showToast({
            message: '退出登录！',
            duration: 500
          });
          router.replaceUrl({
            url: 'pages/Login',
            params: {
              firstLogin: false
            }
          })
        })
      }
      .width('100%')
      .height("100%")
      .backgroundColor("#383838")
      .shadow({
        radius: this.shadowRadius,
        color: '#95000000',
        offsetX: vp2px(-15),
        offsetY: vp2px(0)
      })


      Stack() {
        Navigation(this.pageStack) {
          Tabs({
            barPosition: BarPosition.Start,
            controller: this.controller
          }) {
            TabContent() {
              Column() {
                home({ libraryId: this.selectedLibraryId })
              }
              .width('100%')
              .height('100%')
              .backgroundImage($rawfile('background.jpg'))
              .backgroundImageSize(ImageSize.Cover)
            }
            .width('100%')
            .height('100%')
            .tabBar(this.TabBuilder("首页", 0, $rawfile('tabs/home_a.png')))

            TabContent() {
              library({ libraryId: this.selectedLibraryId })
            }
            .width('100%')
            .height('100%')
            .tabBar(this.TabBuilder("媒体库", 1, $rawfile('tabs/home_a.png')))

            TabContent() {
              Column()
                .width('100%')
                .height('100%')
                .backgroundImage($rawfile('background.jpg'))
                .backgroundImageSize(ImageSize.Cover)
            }
            .width('100%')
            .height('100%')
            .tabBar(this.TabBuilder("系列", 2, $rawfile('tabs/home_a.png')))

            TabContent() {
              Column()
                .width('100%')
                .height('100%')
                .backgroundColor("#333333")
            }
            .width('100%')
            .height('100%')
            .tabBar(this.TabBuilder("收藏", 3, $rawfile('tabs/home_a.png')))

            TabContent() {
              Column()
                .width('100%')
                .height('100%')
                .backgroundColor("#333333")
            }
            .width('100%')
            .height('100%')
            .tabBar(this.TabBuilder("作者", 4, $rawfile('tabs/home_a.png')))
          }
          .width("100%")
          .height('100%')
          .barHeight(40)
          .onChange((index: number) => {
            this.index = index
          })
          .visibility(this.pageIndex === 0 ? Visibility.Visible : Visibility.None)

          Column() {
            Text("用户信息统计")
              .fontSize(40)
              .fontColor(Color.White)
              .width('100%')
              .height('100%')
              .textAlign(TextAlign.Center)
          }
          .backgroundColor("#333333")
          .width("100%")
          .height('100%')
          .visibility(this.pageIndex === 1 ? Visibility.Visible : Visibility.None)

          Column() {
            Text("设置")
              .fontSize(40)
              .fontColor(Color.White)
              .width('100%')
              .height('100%')
              .textAlign(TextAlign.Center)
          }
          .backgroundColor("#333333")
          .width("100%")
          .height('100%')
          .visibility(this.pageIndex === 2 ? Visibility.Visible : Visibility.None)

          Column() {
            Detail()
          }
          .backgroundColor("#333333")
          .width("100%")
          .height('100%')
          .visibility(this.pageIndex === 3 ? Visibility.Visible : Visibility.None)

          // .transition(TransitionEffect.opacity(0).animation({ curve: curves.springMotion(0.6, 1) }))
        }
        .mode(NavigationMode.Stack)
        .padding({ top: this.statusBarHeight })
        .title(this.titlebar())
        .titleMode(NavigationTitleMode.Mini)
        .hideBackButton(true)
        .backgroundColor('#232323')

        Column()
          .width('100%')
          .height(5)
          .shadow({
            offsetX: 0,
            offsetY: 12,
            radius: 10,
            color: '#95000000'
          })
          .margin({ top: this.statusBarHeight + 51 })

        Column() {
          Row() {
            Image(this.showProgressTransfer === false ?
            fileUri.getUriFromPath(filesDir + `/covers/${this.nowPlayingItem.id}.jpg`) : $rawfile('nocover.jpg'))
              .alt($rawfile('nocover.jpg'))
              .width(60)
              .aspectRatio(1)
              .borderRadius(10)
              .objectFit(ImageFit.Fill)
              .margin({ left: 15, right: 5, bottom: 10 })
            Column() {
              Marquee({
                start: true,
                step: 3,
                src: this.playTitle
              })
                .fontColor(Color.White)
                .fontSize(18)
                .width('auto')
              Text(this.nowPlayingItem.media.metadata.authorName)
                .fontColor(Color.White)
                .fontSize(16)
                .width('auto')
                .margin({ top: 5 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .margin({ bottom: 15 })
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .layoutWeight(1)

            Blank()
              .margin({ bottom: 10 })

            Button({ type: ButtonType.Circle }) {
              Image($rawfile('rewind.png'))
                .width(30)
                .height(30)
            }
            .width(40)
            .height(40)
            .margin({ right: 5, bottom: 10 })
            .backgroundColor('#00000000')
            .onClick(() => {
              if (this.nowPlayedTime - 10 < 0) {
                this.nowPlayedTime = 0
              } else {
                this.nowPlayedTime -= 10
              }
              this.nowPlayedProgress = this.nowPlayedTime / this.nowPlayingDuration * 100
              this.avPlayer!.seek(this.nowPlayedTime * 1000)
            })

            Button({ type: ButtonType.Circle }) {
              Image(this.isPlaying === true ? $rawfile('suspend.png') : $rawfile('play.png'))
                .width(30)
                .height(30)
            }
            .width(50)
            .height(50)
            .margin({ right: 5, bottom: 10 })
            .backgroundColor('#383838')
            .onClick(() => {
              this.isPlaying = !this.isPlaying
              this.isPlayingTransfer = this.isPlaying
              if (this.isPlaying === false) {
                this.avPlayer!.pause()
              } else {
                this.avPlayer!.play()
              }
            })

            Button({ type: ButtonType.Circle }) {
              Image($rawfile('forward.png'))
                .width(30)
                .height(30)
            }
            .width(40)
            .height(40)
            .margin({ right: 5, bottom: 10 })
            .backgroundColor('#00000000')
            .onClick(() => {
              if (this.nowPlayedTime + 10 > this.nowPlayingDuration) {
                this.nowPlayedTime = this.nowPlayingDuration
              } else {
                this.nowPlayedTime += 10
              }
              this.nowPlayedProgress = this.nowPlayedTime / this.nowPlayingDuration * 100
              this.avPlayer!.seek(this.nowPlayedTime * 1000)
            })
          }
          .width('100%')
          .height(90)
          .backgroundColor('#232323')
          .shadow({
            offsetX: 0,
            offsetY: -12,
            radius: 10,
            color: '#95000000'
          })
          .visibility(this.startPlaying === true ? Visibility.Visible : Visibility.None)
          .bindContentCover(this.showPlay, this.bindContentCoverBuilder(), {
            modalTransition: ModalTransition.NONE,
          })
          .onClick(() => {
            this.showPlayTransfer = true;
            setTimeout(() => {
              this.startPlayingTransfer = false
            }, 500);
          })
          .transition(TransitionEffect.translate({ y: 100 }).animation({ curve: curves.springMotion(0.6, 1) }))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
        .hitTestBehavior(HitTestMode.Transparent)
      }
      .alignContent(Alignment.Top)
    }
    .width("100%")
    .height('100%')

    .showSideBar(this.sidebarShow)
    .controlButton({
      top: this.statusBarHeight + 13,
      width: 26,
      height: 26,
      icons: {
        shown: $rawfile('sidebar.png'),
        hidden: $rawfile('sidebar.png')
      }
    })
    .sideBarPosition(SideBarPosition.End)
    .onChange((show: boolean) => {
      if (show === true) {
        this.shadowRadius = 50
        this.sidebarShow = true
      } else {
        this.shadowRadius = 0
        this.sidebarShow = false
      }
    })
  }
}