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

export interface AudioFileMetadata {
  filename: string;
  ext: string;
  path: string;
  relPath: string;
  size: number;
  mtimeMs: number;
  ctimeMs: number;
  birthtimeMs: number;
}

export interface AudioFile {
  index: number;
  ino: string;
  metadata: AudioFileMetadata;
  addedAt: number;
  updatedAt: number;
  trackNumFromMeta: number | null;
  discNumFromMeta: number | null;
  trackNumFromFilename: number;
  discNumFromFilename: number | null;
  manuallyVerified: boolean;
  exclude: boolean;
  error: string | null;
  format: string;
  duration: number;
  bitRate: number;
  language: string;
  codec: string;
  timeBase: string;
  channels: number;
  channelLayout: string;
  chapters: string[];
  embeddedCoverArt: string | null;
  metaTags: Record<string, string>;
  mimeType: string;
}

export interface Chapter {
  id: number;
  start: number;
  end: number;
  title: string;
}

export interface Track {
  index: number;
  startOffset: number;
  duration: number;
  title: string;
  contentUrl: string;
  mimeType: string;
  codec: string;
  metadata: AudioFileMetadata;
}

export interface Media {
  id: string;
  libraryItemId: string;
  metadata: Metadata;
  coverPath: string;
  tags: string[];
  audioFiles: AudioFile[];
  chapters: Chapter[];
  duration: number;
  size: number;
  tracks: Track[];
  ebookFile: string | null;
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

export interface UpdateProgress {
  duration: number;
  currentTime: number;
  progress: number;

}

export interface PlayItem {
  id: string;
  userId: string;
  libraryId: string;
  libraryItemId: string;
  bookId: string;
  episodeId: string | null;
  mediaType: string;
  metadata: Metadata;
  chapters: Chapter[];
  displayTitle: string;
  displayAuthor: string;
  coverPath: string;
  duration: number;
  playMethod: number;
  mediaPlayer: string;
  deviceInfo: DeviceInfo;
  serverVersion: string;
  date: string;
  dayOfWeek: string;
  timeListening: number;
  startTime: number;
  currentTime: number;
  startedAt: number;
  updatedAt: number;
  audioTracks: Track[];
  videoTrack: string | null;
}

export interface DeviceInfo {
  id: string;
  userId: string;
  deviceId: string;
  ipAddress: string;
  clientVersion: string;
  clientName: string;
}

export interface PlayData {
  deviceInfo: DeviceInfo,
  forceDirectPlay: boolean
}