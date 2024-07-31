import { router } from '@kit.ArkUI';
import { createConfig, createCoverDir, clearCovers } from '../util/fs'

@Entry
@Component
struct Index {
  aboutToAppear() {
    createConfig()
    createCoverDir()
    clearCovers()
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