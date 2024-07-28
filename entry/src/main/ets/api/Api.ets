import axios, { Axios, AxiosResponse } from '@ohos/axios'
import { LoginInfo, User, Library, LibraryItem, Chapter } from './Interface'

// axios.defaults.baseURL = 'http://192.168.0.106:13378'
axios.defaults.headers.post['Content-Type'] = 'application/json'

let authToken: string = ""
let itemId: string = ""
let libraryItems: string[] = []
let chapters: string[] = []
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
      baseURL: baseUrl
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
    library = response.data.libraries
    library.forEach(element => {
      libraryNames.push(element.name)
    });
    console.log("媒体库", libraryNames)
  } catch (error) {
    console.log("获取媒体库失败！")
    console.error(JSON.stringify(error));
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
    return []
  }
}

export async function getItem() {
  const api: Axios = createApi()
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/items/${itemId}`)
    response.data.media.chapters.forEach((element: Chapter) => {
      chapters.push(element.title)
    });
    console.log("Chapters:", chapters);
  } catch (error) {
    console.error(JSON.stringify(error));
  }
}

export async function getCover(itemId: string) {
  const api: Axios = createApi()
  try {
    const response: AxiosResponse =
      await api.get<string, AxiosResponse<string>, null>(`/api/items/${itemId}/cover`,
        { params: { responseType: 'arraybuffer' } })
    console.log("图片", response.data)
  } catch (error) {
    console.error(JSON.stringify(error));
  }
}