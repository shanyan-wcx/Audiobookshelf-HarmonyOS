export interface LoginInfo {
  server: string,
  username: string,
  password: string
}

export interface User {
  username: string,
  password: string
}

export interface Config {
  loginInfo: LoginInfo,
  rememberLoginInfo: Boolean
}

export interface LibrarySettings {
  coverAspectRatio: number;
  disableWatcher: boolean;
  skipMatchingMediaWithAsin: boolean;
  skipMatchingMediaWithIsbn: boolean;
  autoScanCronExpression: string | null;
}

export interface Folder {
  id: string;
  fullPath: string;
  libraryId: string;
  addedAt?: number;
}

export interface Library {
  id: string;
  name: string;
  folders: Folder[];
  displayOrder: number;
  icon: string;
  mediaType: string;
  provider: string;
  settings: LibrarySettings;
  createdAt: number;
  lastUpdate: number;
}

export interface Metadata {
  title: string;
  titleIgnorePrefix: string;
  subtitle: string | null;
  authorName: string;
  authorNameLF: string;
  narratorName: string;
  seriesName: string;
  genres: string[];
  publishedYear: string;
  publishedDate: string | null;
  publisher: string | null;
  description: string;
  isbn: string | null;
  asin: string | null;
  language: string;
  explicit: boolean;
  abridged: boolean;
}

export interface Media {
  id: string;
  metadata: Metadata;
  coverPath: string;
  tags: string[];
  numTracks: number;
  numAudioFiles: number;
  numChapters: number;
  duration: number;
  size: number;
}

export interface LibraryItem {
  id: string;
  ino: string;
  oldLibraryItemId: string | null;
  libraryId: string;
  folderId: string;
  path: string;
  relPath: string;
  isFile: boolean;
  mtimeMs: number;
  ctimeMs: number;
  birthtimeMs: number;
  addedAt: number;
  updatedAt: number;
  isMissing: boolean;
  isInvalid: boolean;
  mediaType: string;
  media: Media;
  numFiles: number;
  size: number;
}

export interface Chapter {
  id: number;
  start: number;
  end: number;
  title: string;
}

export interface Progress {
  id: string;
  libraryItemId: string;
  episodeId: string;
  duration: number;
  progress: number;
  currentTime: number;
  isFinished: boolean;
  hideFromContinueListening: boolean;
  lastUpdate: number;
  startedAt: number;
  finishedAt: number | null;
}