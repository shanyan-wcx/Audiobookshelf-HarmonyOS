import { router } from '@kit.ArkUI';
import { createConfig,   createCoverDir } from '../util/fs'

@Entry
@Component
struct Index {
  aboutToAppear() {
    createConfig()
    createCoverDir()
    router.replaceUrl({
      url: 'pages/Login',
      params: {
        firstLogin: true
      }
    })
  }

  build() {
  }
}