import { router } from '@kit.ArkUI';
import { createConfig } from '../util/fs'

@Entry
@Component
struct Index {
  aboutToAppear() {
    createConfig()
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