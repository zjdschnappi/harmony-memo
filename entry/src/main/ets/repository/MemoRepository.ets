//

import MemoDao from '../dao/MemoDao';
import { IMemoCreateModel,IMemoDetailModel, IMemoUpdateModel } from '../model/Memo';
import { formatDate } from '../utils/DateUtil';

class MemoRepository {
  // 创建新备忘录
  async createMemo(content: IMemoCreateModel): Promise<string> {
    if (!content.title.trim()) {
      throw new Error('备忘录标题不能为空');
    }

    const bizId = this.generateBizId();
    const memo: IMemoDetailModel = {
      memoId:bizId,
      title:content.title,
      content:content.content,
      isPinned: false,
      isArchived: false,
      createdTime: formatDate(new Date()),
      modifiedTime: formatDate(new Date())
    };

    const id = await MemoDao.insert(memo);
    return bizId;
  }

  // 更新备忘录内容
  async updateMemoContent(content: IMemoUpdateModel): Promise<string> {
    const existing = await MemoDao.getById(content.memoId);
    if (!existing) {
      throw new Error('找不到备忘录');
    }

    const updated: IMemoDetailModel = {
      memoId: existing.memoId,
      isPinned: existing.isPinned,
      isArchived: existing.isArchived,
      createdTime: existing.createdTime,
      title:content.title,
      content:content.content,
      modifiedTime: formatDate(new Date())
    };

    await MemoDao.update(updated);
    return content.memoId;
  }

  // 切换置顶状态
  async togglePin(id: string): Promise<boolean> {
    const memo = await MemoDao.getById(id);
    if (!memo) {
      throw new Error('找不到备忘录');
    }

    memo.isPinned = !memo.isPinned;

    await MemoDao.update(memo);
    return true;
  }

  // 归档备忘录
  async archiveMemo(id: string): Promise<boolean> {
    const memo = await MemoDao.getById(id);
    if (!memo) {
      throw new Error('找不到备忘录');
    }

    memo.isArchived = true;

    await MemoDao.update(memo);
    return true;
  }

  // 获取备忘录详情
  async getMemoById(id: string): Promise<IMemoDetailModel|null> {
    return await MemoDao.getById(id)

  }


  // 删除备忘录
  async deleteMemo(id: string): Promise<void> {
    const count = await MemoDao.delete(id);
    if (count === 0) {
      throw new Error('删除失败，备忘录不存在');
    }
  }

  // 获取所有活动备忘录
  async getActiveMemos(): Promise<IMemoDetailModel[]> {
    try {
      const all = await MemoDao.getAll();
      return all.filter(m => !m.isArchived);
    }catch (e){
      return Promise.resolve([])
      console.log(e)
    }

  }

  // 获取已归档备忘录
  async getArchivedMemos(): Promise<IMemoDetailModel[]> {
    const all = await MemoDao.getAll();
    return all.filter(m => m.isArchived);
  }

  // 获取置顶备忘录
  async getPinnedMemos(): Promise<IMemoDetailModel[]> {
    return await MemoDao.getPinned();
  }


  // 生成业务ID
  private generateBizId(): string {
    const timestamp = new Date().getTime().toString(36);
    const random = Math.random().toString(36).substring(2, 8);
    return `MEMO-${timestamp}-${random}`.toUpperCase();
  }
}

export default new MemoRepository();