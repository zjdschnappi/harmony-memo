//

import TodoDao from '../dao/TodoDao';
import { ITodoCreateModel,ITodoDetailModel, ITodoUpdateModel, PriorityLevel } from '../model/Todo';
import { formatDate } from '../utils/DateUtil';

class TodoRepository {
  // 创建新备忘录
  async create(content: ITodoCreateModel): Promise<string> {
    if (!content.title.trim()) {
      throw new Error('待办不能为空');
    }

    const bizId = this.generateBizId();
    const todo: Partial<ITodoDetailModel> = {
      todoId:bizId,
      title:content.title,
      isCompleted: false,
      createdTime: formatDate(new Date()),
      modifiedTime: formatDate(new Date()),
      dueTime: content.dueTime,
      location: content.location,
      priority: PriorityLevel.NORMAL,
      memo: content.memo
    };

    const id = await TodoDao.insert(todo);
    return bizId;
  }

  // 更新待办内容
  async update(content: ITodoUpdateModel): Promise<string> {
    const existing = await TodoDao.getById(content.todoId);
    if (!existing) {
      throw new Error('找不到待办');
    }

    const updated: ITodoUpdateModel = {
      todoId: existing.todoId,
      isCompleted: content.isCompleted,
      title:content.title,
      dueTime: content.dueTime,
      location: content.location,
      memo: content.memo,
    };

    await TodoDao.update(updated);
    return content.todoId;
  }

  // 切换完成状态
  async toggleCompleted(id: string,checked:boolean): Promise<boolean> {
    const todo = await TodoDao.getById(id);
    if (!todo) {
      throw new Error('找不到待办');
    }

    todo.isCompleted = checked

    await TodoDao.update(todo as ITodoUpdateModel);
    return true;
  }


  // 获取待办详情
  async getDetailById(id: string): Promise<ITodoDetailModel|null> {
    return await TodoDao.getById(id)

  }


  // 删除备忘录
  async delete(ids: string[]): Promise<void> {
    const count = await TodoDao.delete(ids);
    if (count === 0) {
      throw new Error('删除失败，待办不存在');
    }
  }

  // 获取所有活动备忘录
  async getTodos(): Promise<ITodoDetailModel[]> {
    try {
      const all = await TodoDao.getAll();
      return all
    }catch (e){
      return Promise.resolve([])
      console.log(e)
    }

  }

  // 获取置顶备忘录
  async getCompletedTodos(): Promise<ITodoDetailModel[]> {
    return await TodoDao.getCompleted();
  }


  // 生成业务ID
  private generateBizId(): string {
    const timestamp = new Date().getTime().toString(36);
    const random = Math.random().toString(36).substring(2, 8);
    return `MEMO-${timestamp}-${random}`.toUpperCase();
  }
}

export default new TodoRepository();