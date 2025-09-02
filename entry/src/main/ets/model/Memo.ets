

// 表情模型类
export class EmojiModel {
  imgSrc: Resource; // 图片资源
  meaning: string = ''; // 表情所表示的含义

  constructor(imgSrc: Resource, meaning: string) {
    this.imgSrc = imgSrc;
    this.meaning = meaning;
  }
}

// 表情数据
export const EmojiData = [
  new EmojiModel($rawfile('emojis/01.png'), '大笑'),
  new EmojiModel($rawfile('emojis/02.png'), '微笑'),
  new EmojiModel($rawfile('emojis/03.png'), '亲亲'),
  new EmojiModel($rawfile('emojis/04.png'), '熬夜'),
  new EmojiModel($rawfile('emojis/05.png'), '羡慕'),
  new EmojiModel($rawfile('emojis/06.png'), '呲牙笑'),
  new EmojiModel($rawfile('emojis/07.png'), '好害羞'),
  new EmojiModel($rawfile('emojis/08.png'), '偷笑'),
  new EmojiModel($rawfile('emojis/09.png'), '见钱眼开'),
  new EmojiModel($rawfile('emojis/10.png'), '眨眼'),
  new EmojiModel($rawfile('emojis/11.png'), '坏笑'),
  new EmojiModel($rawfile('emojis/12.png'), '好害羞'),
  new EmojiModel($rawfile('emojis/13.png'), '困惑'),
  new EmojiModel($rawfile('emojis/14.png'), '鼓掌'),
  new EmojiModel($rawfile('emojis/15.png'), '可怜'),
  new EmojiModel($rawfile('emojis/16.png'), '抠鼻'),
  new EmojiModel($rawfile('emojis/17.png'), '打哈欠'),
  new EmojiModel($rawfile('emojis/18.png'), '睡觉'),
  new EmojiModel($rawfile('emojis/19.png'), '叹气'),
  new EmojiModel($rawfile('emojis/20.png'), '惊讶'),
  new EmojiModel($rawfile('emojis/21.png'), '小声点'),
  new EmojiModel($rawfile('emojis/22.png'), '吐你一身'),
  new EmojiModel($rawfile('emojis/23.png'), '闭嘴'),
  new EmojiModel($rawfile('emojis/24.png'), '打你'),
  new EmojiModel($rawfile('emojis/25.png'), '抓狂'),
  new EmojiModel($rawfile('emojis/26.png'), '好委屈'),
  new EmojiModel($rawfile('emojis/27.png'), '你好讨厌'),
  new EmojiModel($rawfile('emojis/28.png'), '我真生气了'),
  new EmojiModel($rawfile('emojis/29.png'), '翻白眼'),
  new EmojiModel($rawfile('emojis/30.png'), '伤心死了'),
  new EmojiModel($rawfile('emojis/31.png'), '难过'),
  new EmojiModel($rawfile('emojis/32.png'), '酷'),
];

export type IMemoContentItem = RichEditorImageSpanResult | RichEditorTextSpanResult

export const CONTENT_VERSION = 1

export interface  IMemoDbEntityModel {
  memo_id: string
  title: string
  is_pinned:number;
  is_archived:number
  content: string;
  created_time: number;
  modified_time: number;
  content_version:number
}


export interface IMemoSimpleListItemModel {
  memoId: string
  title: string
  simpleContent: string;
  createdTime: string;
  modifiedTime: string;
  imgUrl:ResourceStr[]
  isPinned: boolean
  isArchived: boolean
}

export interface IMemoDetailModel {
  memoId: string
  title: string
  isPinned:boolean;
  isArchived:boolean
  content: IMemoContentItem[];
  createdTime: string;
  modifiedTime: string;
}

export interface IMemoCreateModel {
  title: string
  content: IMemoContentItem[];
}

export interface IMemoUpdateModel {
  memoId: string;
  title: string
  content: IMemoContentItem[];
}


@ObservedV2
export class MemoSimpleListItemModel implements  IMemoSimpleListItemModel {
  @Trace memoId:string
  @Trace title:string
  @Trace simpleContent:string
  @Trace createdTime:string
  @Trace modifiedTime: string
  @Trace imgUrl:ResourceStr[]
  @Trace isPinned: boolean
  @Trace isArchived: boolean

  constructor(
    memoId: string,
    title: string,
    simpleContent: string,
    createdTime:string,
    modifiedTime: string,
    imgUrl:ResourceStr[],
    isPinned: boolean,
    isArchived: boolean
  ) {
    this.memoId = memoId;
    this.simpleContent = simpleContent
    this.createdTime = createdTime;
    this.modifiedTime = modifiedTime;
    this.title = title;
    this.imgUrl = imgUrl
    this.isPinned = isPinned
    this.isArchived = isArchived

  }
}


export class MemoDetailModel implements IMemoDetailModel {
  memoId:string
  title:string
  isPinned: boolean
  isArchived: boolean
  content:IMemoContentItem[]
  createdTime:string
  modifiedTime: string
  imgUrl:ResourceStr[]

  constructor(
    memoId: string,
    title: string,
    content: IMemoContentItem[],
    isPinned: boolean,
    isArchived: boolean,
    createTime:string,
    modifiedTime: string,
    imgUrl:ResourceStr[],
  ) {
    this.memoId = memoId;
    this.content = content
    this.createdTime = createTime;
    this.modifiedTime = modifiedTime;
    this.isPinned = isPinned;
    this.isArchived = isArchived;
    this.title = title;
    this.imgUrl = imgUrl
  }
}
