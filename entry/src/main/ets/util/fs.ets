import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { Config } from '../api/Interface'

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

export function createConfig(): void {
  let config: Config = {
    loginInfo: {
      server: '',
      username: '',
      password: ''
    },
    autoLogin: false,
    jumpTime: 10
  }
  // fs.unlinkSync(filesDir + '/config.json')
  let configStatus = fs.accessSync(filesDir + '/config.json')
  if (configStatus === true) {
    console.log("配置文件存在。")
  } else {
    console.log("配置文件不存在。")
    let file = fs.openSync(filesDir + '/config.json', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, JSON.stringify(config));
    fs.closeSync(file);
  }
  console.log("配置文件位置", filesDir + '/config.json')
}

export function readConfig(): Config {
  let config: Config
  let file = fs.openSync(filesDir + '/config.json', fs.OpenMode.READ_WRITE)
  let arrayBuffer = new ArrayBuffer(4096);
  let readLen = fs.readSync(file.fd, arrayBuffer);
  let buf = buffer.from(arrayBuffer, 0, readLen);
  config = JSON.parse(buf.toString())
  console.log("读取配置", JSON.stringify(config))
  fs.closeSync(file);
  return config
}

export function writeConfig(config: Config) {
  let file = fs.openSync(filesDir + '/config.json', fs.OpenMode.READ_WRITE)
  fs.writeSync(file.fd, JSON.stringify(config));
  console.log("写入配置", JSON.stringify(config))
  fs.closeSync(file);
}

export function getPixelMap(cover: ArrayBuffer): PixelMap {
  const imageSource: image.ImageSource = image.createImageSource(cover);
  let pixelMap = imageSource.createPixelMapSync()
  return pixelMap
}