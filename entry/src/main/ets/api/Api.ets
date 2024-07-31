import axios, { Axios, AxiosResponse } from '@ohos/axios'
import { promptAction } from '@kit.ArkUI';
import { LoginInfo, User, Library, LibraryItem, Chapter, Progress } from './Interface'
import { downloadCover } from '../util/fs'

axios.defaults.headers.post['Content-Type'] = 'application/json'

let authToken: string = ""
let baseUrl = ""

function createApi() {
  const api: Axios = axios.create({
    baseURL: baseUrl,
    timeout: 10000,
    headers: { 'Authorization': `Bearer ${authToken}` }
  });
  return api
}

export async function getLogin(loginInfo: LoginInfo) {
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
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function getLogout() {
  const api: Axios = createApi()
  try {
    const response: AxiosResponse = await api.post<string, AxiosResponse<string>, User>('/logout')
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
    const response: AxiosResponse = await api.get<string, AxiosResponse<string>, null>('/api/libraries')
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
      await api.get<string, AxiosResponse<string>, null>(`/api/libraries/${libraryId}/items`,
        { params: { minified: true } })
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
        { params: { minified: true } })
    response.data.results.forEach((element: LibraryItem) => {
      libraryItems.push(element)
    });
    libraryItems.forEach(element => {
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
        { params: { minified: true } })
    response.data.results.forEach((element: LibraryItem) => {
      libraryItems.push(element)
    });
    libraryItems.forEach(element => {
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
      await api.get<string, AxiosResponse<string>, null>(`/api/items/${itemId}`)
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
        { params: { responseType: 'arraybuffer' } })
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
      await api.get<string, AxiosResponse<string>, null>(`/api/me/progress/${itemId}`)
    progress = response.data
    return progress
  } catch (error) {
    progress.libraryItemId = itemId
    return progress
  }
}