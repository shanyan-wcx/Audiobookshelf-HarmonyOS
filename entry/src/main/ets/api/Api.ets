import axios, { Axios, AxiosResponse } from '@ohos/axios'
import { promptAction } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  LoginInfo,
  User,
  Library,
  LibraryItem,
  Chapter,
  Progress,
  PlayItem,
  DeviceInfo,
  PlayData,
  UpdateProgress
} from './Interface'
import { downloadCover } from '../util/fs'

axios.defaults.headers.post['Content-Type'] = 'application/json'

let authToken: string = ""
let userId: string = ""
let baseUrl = ""

const session = rcp.createSession();

function createApi() {
  const api: Axios = axios.create({
    baseURL: baseUrl,
    headers: {
      'Authorization': `Bearer ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  return api
}

export async function getLogin(loginInfo: LoginInfo): Promise<string | null> {
  let user: User = {
    username: loginInfo.username,
    password: loginInfo.password
  }
  baseUrl = loginInfo.server
  try {
    const response: AxiosResponse = await axios.post<string, AxiosResponse<string>, User>('/login', user, {
      baseURL: baseUrl,
      timeout: 10000
    })
    console.log("Token:", JSON.stringify(response.data.user.token));
    authToken = response.data.user.token
    userId = response.data.user.id
    return authToken
  } catch (error) {
    console.error(JSON.stringify(error));
    return null
  }
}

export async function getLogout() {
  const api: Axios = createApi()
  try {
    const response: AxiosResponse = await api.post<string, AxiosResponse<string>>('/logout', {
      timeout: 10000
    })
    console.log("退出登录！")
  } catch (error) {
    console.error(JSON.stringify(error));
  }
}

export async function getLibraries(): Promise<Library[]> {
  let library: Library[] = []
  let libraryNames: string[] = []
  const api: Axios = createApi()
  try {
    const response: AxiosResponse = await api.get<string, AxiosResponse<string>, null>('/api/libraries', {
      timeout: 10000
    })
    console.log("获取媒体库成功！")

    library = response.data.libraries.filter((item: Library) => {
      return item.mediaType === "book";
    });
    library.forEach(element => {
      libraryNames.push(element.name)
    });
    console.log("媒体库", libraryNames)
  } catch (error) {
    console.log("获取媒体库失败！")
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '获取媒体库失败，请检查网络！',
      duration: 500
    });
  }
  return library
}

export async function getLibrarieItems(libraryId: string): Promise<LibraryItem[]> {
  const api: Axios = createApi()
  let libraryItems: LibraryItem[] = []
  let itemTitles: string[] = []
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/libraries/${libraryId}/items`, {
        params: { minified: true },
        timeout: 10000
      })
    response.data.results.forEach((element: LibraryItem) => {
      libraryItems.push(element)
    });
    libraryItems.forEach(element => {
      itemTitles.push(element.media.metadata.title)
    });
    console.log("项目", itemTitles.toString());
    return libraryItems
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '获取媒体库内容失败，请检查网络！',
      duration: 500
    });
    return []
  }
}

export async function getLibrarieItemsInProgress(libraryId: string): Promise<LibraryItem[]> {
  const api: Axios = createApi()
  let libraryItems: LibraryItem[] = []
  let itemTitles: string[] = []
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/libraries/${libraryId}/items?filter=progress.aW4tcHJvZ3Jlc3M%3D`,
        {
          params: { minified: true },
          timeout: 50000,
          readTimeout:10000
        })
    response.data.results.forEach((element: LibraryItem) => {
      libraryItems.push(element)
      itemTitles.push(element.media.metadata.title)
    });
    console.log("进行中项目", itemTitles.toString());
    return libraryItems
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '获取进行中项目失败，请检查网络！',
      duration: 500
    });
    return []
  }
}

export async function getLibrarieItemsFinished(libraryId: string): Promise<LibraryItem[]> {
  const api: Axios = createApi()
  let libraryItems: LibraryItem[] = []
  let itemTitles: string[] = []
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/libraries/${libraryId}/items?filter=progress.ZmluaXNoZWQ%3D`,
        {
          params: { minified: true },
          timeout: 50000,
          readTimeout:10000
        })
    response.data.results.forEach((element: LibraryItem) => {
      libraryItems.push(element)
      itemTitles.push(element.media.metadata.title)
    });
    console.log("已完成项目", itemTitles.toString());
    return libraryItems
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '获取已完成项目失败，请检查网络！',
      duration: 500
    });
    return []
  }
}

export async function getItem(itemId: string): Promise<Chapter[]> {
  const api: Axios = createApi()
  let chapters: string[] = []
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/items/${itemId}`, {
        timeout: 10000
      })
    response.data.media.chapters.forEach((element: Chapter) => {
      chapters.push(element.title)
    });
    console.log("Chapters:", chapters);
    return response.data.media.chapters
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '获取章节失败，请检查网络！',
      duration: 500
    });
    return []
  }
}

export async function getCover(itemId: string) {
  const api: Axios = createApi()
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/items/${itemId}/cover?format=jpeg`,
        {
          params: { responseType: 'arraybuffer' },
          timeout: 10000
        })
    downloadCover(itemId, response.data)
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '获取封面失败，请检查网络！',
      duration: 500
    });
  }
}

export async function getProgress(itemId: string): Promise<Progress> {
  const api: Axios = createApi()
  let progress: Progress = {
    id: '',
    libraryItemId: itemId,
    episodeId: '',
    duration: 0,
    progress: 0,
    currentTime: 0,
    isFinished: false,
    hideFromContinueListening: false,
    lastUpdate: 0,
    startedAt: 0,
    finishedAt: null
  }
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/me/progress/${itemId}`, {
        timeout: 10000
      })
    progress = response.data
    return progress
  } catch (error) {
    progress.libraryItemId = itemId
    // promptAction.showToast({
    //   message: '获取进度失败，请检查网络！',
    //   duration: 500
    // });
    return progress
  }
}

export async function getPlayItem(itemId: string): Promise<PlayItem> {
  const api: Axios = createApi();
  let playItem: PlayItem = {
    id: '',
    userId: '',
    libraryId: '',
    libraryItemId: itemId,
    bookId: '',
    episodeId: null,
    mediaType: '',
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
    chapters: [],
    displayTitle: '',
    displayAuthor: '',
    coverPath: '',
    duration: 0,
    playMethod: 0,
    mediaPlayer: '',
    deviceInfo: {
      id: '',
      userId: '',
      deviceId: '',
      ipAddress: '',
      clientVersion: '',
      clientName: '',
    },
    serverVersion: '',
    date: '',
    dayOfWeek: '',
    timeListening: 0,
    startTime: 0,
    currentTime: 0,
    startedAt: 0,
    updatedAt: 0,
    audioTracks: [],
    videoTrack: null
  }
  try {
    const response: AxiosResponse =
      await api.post<string, AxiosResponse<string>, PlayData>(`/api/items/${itemId}/play`, {
        deviceInfo: {
          id: '00000000',
          userId: userId,
          deviceId: '00000000',
          ipAddress: '',
          clientName: 'Abs-HarmonyOS',
          clientVersion: "0.0.1"
        },
        forceDirectPlay: true
      }, {
        timeout: 10000
      })
    playItem = response.data
    console.log("获取到播放项目", playItem.libraryItemId)
    console.log("当前位置", playItem.currentTime)
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '获取播放项目失败，请检查网络！',
      duration: 500
    });
  }
  return playItem
}

// export async function updateProgress(itemId: string, progress: UpdateProgress) {
//   const api: Axios = createApi();
//   try {
//     const response: AxiosResponse =
//       await api.post<string, AxiosResponse<string>, UpdateProgress>(`/api/me/progress/${itemId}`, progress, {
//         headers: {
//           'X-HTTP-Method-Override': 'PATCH' // 通过这个头部字段表明实际请求方法为PATCH
//         }
//       })
//     console.log(response.data)
//   } catch (error) {
//     console.error(JSON.stringify(error));
//     promptAction.showToast({
//       message: '上传进度失败，请检查网络！',
//       duration: 500
//     });
//   }
// }

export async function updateProgress(itemId: string, progress: UpdateProgress) {
  let req = new rcp.Request(baseUrl+`/api/me/progress/${itemId}`, 'PATCH')
  req.content = JSON.stringify(progress)
  req.headers = {
    'Authorization': `Bearer ${authToken}`,
    'Content-Type': 'application/json'
  }
  try {
    const response: rcp.Response = await session.fetch(req)
    console.log("上传进度成功", response);
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '上传进度失败，请检查网络！',
      duration: 500
    });
  }
}