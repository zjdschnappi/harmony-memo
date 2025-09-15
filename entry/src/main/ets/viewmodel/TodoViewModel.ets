import TodoRepository from '../repository/TodoRepository';
import { ITodoCreateModel, ITodoDetailModel,
  ITodoListItemModel, ITodoUpdateModel, } from '../model/Todo';

class TodoViewModel {
  // 创建新待办
  async create(title: string): Promise<string> {
    const memoContent: ITodoCreateModel = {
      title,
    };

    return await TodoRepository.createMemo(memoContent);
  }

  // 更新备忘录内容
  async updateMemo(data:ITodoUpdateModel): Promise<string> {
    return await TodoRepository.update(data);
  }

  // 切换置顶状态
  async toggleCompleted(id: string): Promise<boolean> {
    return await TodoRepository.togglePin(id);
  }

  async getDetailById(id: string): Promise<ITodoDetailModel|null> {
    return await TodoRepository.getDetailById(id)
  }


  // 删除待办
  async delete(ids: string[]): Promise<void> {
    await TodoRepository.delete(ids);
  }

  // 获取所有活动备忘录
  async getTodos(): Promise<ITodoListItemModel[]> {
    let result =  await TodoRepository.getTodos();
    return this.convert2SimpleList(result)
  }


  // 获取置顶备忘录
  async getCompletedMemos(): Promise<ITodoListItemModel[]> {
    let result = await TodoRepository.getCompletedMemos();
    return this.convert2SimpleList(result)
  }
  //
  convert2SimpleList(list:ITodoDetailModel[]):ITodoListItemModel[]{
    return list.map(item=>{
      return {
        id: item.todoId,
        todoId:item.todoId,
        title: item.title,
        priority: item.priority,
        isCompleted: item.isCompleted,
        createdTime:item.createdTime,
        modifiedTime:item.modifiedTime,
        dueTime: item.dueTime,
        locationName: item.location?.name

      } as ITodoListItemModel

    })
  }

}

export default new TodoViewModel();