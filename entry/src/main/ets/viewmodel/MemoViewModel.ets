import MemoRepository from '../repository/MemoRepository';
import { IMemoContentItem, IMemoCreateModel, IMemoDetailModel,
  IMemoSimpleListItemModel, } from '../model/Memo';

class MemoViewModel {
  // 创建新备忘录
  async createMemo(title: string, content: IMemoContentItem[]): Promise<string> {
    const memoContent: IMemoCreateModel = {
      title,
      content
    };

    return await MemoRepository.createMemo(memoContent);
  }

  // 更新备忘录内容
  async updateMemo(id: string,title:string, content: IMemoContentItem[]): Promise<string> {
    return await MemoRepository.updateMemoContent({
      title,
      content,
      memoId:id
    });
  }

  // 切换置顶状态
  async togglePin(id: string): Promise<boolean> {
    return await MemoRepository.togglePin(id);
  }

  async getDetailById(id: string): Promise<IMemoDetailModel|null> {
    return await MemoRepository.getMemoById(id)
  }

  // 归档备忘录
  async archiveMemo(id: string): Promise<boolean> {
    return await MemoRepository.archiveMemo(id);
  }

  // 删除备忘录
  async deleteMemo(ids: string[]): Promise<void> {
    await MemoRepository.deleteMemo(ids);
  }

  // 获取所有活动备忘录
  async getActiveMemos(): Promise<IMemoSimpleListItemModel[]> {
    let result =  await MemoRepository.getActiveMemos();
    return this.convert2SimpleList(result)
  }

  // 获取已归档备忘录
  async getArchivedMemos(): Promise<IMemoSimpleListItemModel[]> {
    let result = await MemoRepository.getArchivedMemos();
    return this.convert2SimpleList(result)
  }

  // 获取置顶备忘录
  async getPinnedMemos(): Promise<IMemoSimpleListItemModel[]> {
    let result = await MemoRepository.getPinnedMemos();
    return this.convert2SimpleList(result)
  }
  //
  convert2SimpleList(list:IMemoDetailModel[]):IMemoSimpleListItemModel[]{
    return list.map(item=>{
      let simple = this.convertContentToSimple(item.content);
      let simpleContent = simple[0];
      let imgUrls = simple[1]
       return {
         id: item.memoId,
         memoId:item.memoId,
         title: item.title,
         simpleContent:simpleContent,
         imgUrl:imgUrls,
         isPinned:item.isPinned,
         isArchived: item.isArchived,
         createdTime:item.createdTime,
         modifiedTime:item.modifiedTime
       } as IMemoSimpleListItemModel

    })
  }

  convertContentToSimple(content:IMemoContentItem[]):[string,ResourceStr[]]{
    let firstContent = '';
    let imgUrls:ResourceStr[] = []
    let res = content?.[0] as RichEditorTextSpanResult
    firstContent = res?.value;

    content.forEach((item)=>{
      let res = item as RichEditorImageSpanResult;
      if(typeof res.valueResourceStr!=='undefined'){
        imgUrls.push(res.valueResourceStr)
      }
    })
    return [
      firstContent,
      imgUrls
    ]

  }
}

export default new MemoViewModel();