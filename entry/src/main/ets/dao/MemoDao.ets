// 封装数据库操作

import Database from '../database/Database';
import relationalStore from '@ohos.data.relationalStore';
import { IMemoDetailModel, CONTENT_VERSION, IMemoContentItem, IMemoDbEntityModel } from '../model/Memo';
import { BusinessError } from '@ohos.base';
import { formatDate } from '../utils/DateUtil';


class MemoDao {
  // 插入备忘录
  async insert(memo: IMemoDetailModel): Promise<number> {
    const store = await Database.getRdbStore();
    const now = Date.now();

    const valueBucket:IMemoDbEntityModel= {
      memo_id: memo.memoId,
      title: memo.title,
      content :JSON.stringify(memo.content),
      is_pinned: memo.isPinned ? 1 : 0,
      is_archived: memo.isArchived ? 1 : 0,
      created_time:  now,
      modified_time: now,
      content_version: CONTENT_VERSION
    };



    const result = await store.insert('memos', valueBucket as never as  relationalStore.ValuesBucket);
    return Number(result);
  }

  // 更新备忘录
  async update(memo: IMemoDetailModel): Promise<number> {
    if (!memo.memoId) throw new Error('Memo ID is required for update');

    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates('memos');
    predicates.equalTo('memo_id', memo.memoId);

    const valueBucket: relationalStore.ValuesBucket = {
      memo_id: memo.memoId,
      title: memo.title,
      is_pinned: memo.isPinned ? 1 : 0,
      is_archived: memo.isArchived ? 1 : 0,
      modified_time: Date.now(),
      content_version: CONTENT_VERSION
    };

    // 更新内容
    if (memo.content) {

      const contentJson = JSON.stringify(memo.content);

      valueBucket.content = contentJson;
    }

    return await store.update(valueBucket, predicates);
  }

  // 删除备忘录
  async delete(id: string): Promise<number> {
    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates('memos');
    predicates.equalTo('memo_id', id);

    // 先获取内容引用以便清理
    const memo = await this.getById(id);

     return await store.delete(predicates);

  }

  // 获取所有备忘录
  async getAll(): Promise<IMemoDetailModel[]> {
    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates('memos');
    predicates.orderByDesc('modified_time');

    const columns = [
      'id', 'memo_id', 'content','title', 'content_version', 'is_pinned', 'is_archived',
      'created_time', 'modified_time'
    ];

    const result = await store.query(predicates, columns);
    return this.processResultSet(result);
  }

  // 获取置顶备忘录
  async getPinned(): Promise<IMemoDetailModel[]> {
    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates('memos');
    predicates.equalTo('is_pinned', 1)
      .orderByDesc('modified_time');

    const result = await store.query(predicates);
    return this.processResultSet(result);
  }

  // 根据ID获取备忘录
  async getById(id: string): Promise<IMemoDetailModel | null> {
    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates('memos');
    predicates.equalTo('memo_id', id);

    const result = await store.query(predicates);
    const memos = await this.processResultSet(result);
    return memos.length > 0 ? memos[0] : null;
  }

  // 处理查询结果集
  private async processResultSet(result: relationalStore.ResultSet): Promise<IMemoDetailModel[]> {
    const memos: IMemoDetailModel[] = [];

    while (result.goToNextRow()) {
      // const id = result.getLong(result.getColumnIndex('id'));
      const memoId = result.getString(result.getColumnIndex('memo_id'));
      const title = result.getString(result.getColumnIndex('title'));
      const contentVersion = result.getLong(result.getColumnIndex('content_version'));
      const isPinned = result.getLong(result.getColumnIndex('is_pinned')) === 1;
      const isArchived = result.getLong(result.getColumnIndex('is_archived')) === 1;
      const createdTime = result.getLong(result.getColumnIndex('created_time'));
      const modifiedTime = result.getLong(result.getColumnIndex('modified_time'));

      let content: IMemoContentItem[]

      const contentJson = result.getString(result.getColumnIndex('content'));
      content = this.parseContent(contentJson, contentVersion);


      memos.push({
        title,
        memoId,
        content,
        isPinned,
        isArchived,
        createdTime:formatDate(new Date(createdTime)),
        modifiedTime:formatDate(new Date(modifiedTime))
      });
    }

    result.close();
    return memos;
  }

  // 解析内容（带版本控制）
  private parseContent(json: string, version: number): IMemoContentItem[] {
    try {
      const raw:IMemoContentItem[] = JSON.parse(json);


      return raw;
    } catch (error) {
      console.error(`Content parse error: ${(error as BusinessError).message}`);
      return []
    }
  }
}

export default new MemoDao();