

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


@Observed
export class MemoSimpleListItemModel implements  IMemoSimpleListItemModel {
  memoId:string
  title:string
  simpleContent:string
  createdTime:string
  modifiedTime: string
  imgUrl:ResourceStr[]

  constructor(
    memoId: string,
    title: string,
    simpleContent: string,
    createdTime:string,
    modifiedTime: string,
    imgUrl:ResourceStr[],
  ) {
    this.memoId = memoId;
    this.simpleContent = simpleContent
    this.createdTime = createdTime;
    this.modifiedTime = modifiedTime;
    this.title = title;
    this.imgUrl = imgUrl

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
