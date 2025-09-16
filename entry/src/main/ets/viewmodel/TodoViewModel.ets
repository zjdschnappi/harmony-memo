import TodoRepository from '../repository/TodoRepository';
import { ITodoCreateModel, ITodoDetailModel,
  ITodoListItemModel, ITodoUpdateModel, } from '../model/Todo';

class TodoViewModel {
  // 创建新待办
  async create(data:ITodoCreateModel): Promise<string> {


    return await TodoRepository.create(data);
  }

  // 更新备忘录内容
  async update(data:ITodoUpdateModel): Promise<string> {
    return await TodoRepository.update(data);
  }

  // 切换置顶状态
  async toggleCompleted(id: string,checked:boolean): Promise<boolean> {
    return await TodoRepository.toggleCompleted(id,checked);
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
  async getCompletedTodos(): Promise<ITodoListItemModel[]> {
    let result = await TodoRepository.getCompletedTodos();
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