// 封装数据库操作

import Database from '../database/Database';
import relationalStore from '@ohos.data.relationalStore';
import { ITodoDetailModel, ITodoDbEntityModel, PriorityLevel, LocationModel, ITodoUpdateModel } from '../model/Todo';
import { BusinessError } from '@ohos.base';
import { formatDate } from '../utils/DateUtil';

const TABLE_NAME = 'todos'

class TodoDao {
  // 插入备忘录
  async insert(item: ITodoDetailModel): Promise<number> {
    const store = await Database.getRdbStore();
    const now = Date.now();

    const valueBucket:ITodoDbEntityModel= {
      todo_id: item.todoId,
      title: item.title,

      is_completed: item.isCompleted ? 1 : 0,

      created_time:  now,
      modified_time: now,
      due_time: item.dueTime? new Date(item.dueTime).valueOf():undefined,
      priority: item.priority?item.priority:PriorityLevel.NORMAL,
      location_name: item.location?.name,
      latitude: item.location?.latitude,
      longitude: item.location?.longitude,
      radius: item.location?.radius,
      memo: item.memo
    };



    const result = await store.insert(TABLE_NAME, valueBucket as never as  relationalStore.ValuesBucket);
    return Number(result);
  }

  // 更新备忘录
  async update(item: ITodoUpdateModel): Promise<number> {
    if (!item.todoId) throw new Error('Todo ID is required for update');

    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('todo_id', item.todoId);

    const valueBucket: relationalStore.ValuesBucket = {
      title: item.title,
      is_completed: item.isCompleted ? 1 : 0,
      due_time: item.dueTime?new Date(item.dueTime).valueOf():null,
      modified_time: Date.now(),
      location_name: item.location?.name||null,
      latitude: item.location?.latitude||null,
      longitude: item.location?.longitude||null,
      radius: item.location?.radius||null,
      memo: item.memo||null
    };



    return await store.update(valueBucket, predicates);
  }

  // 删除备忘录
  async delete(ids: string[]): Promise<number> {
    if(ids.length==0){
      return 0
    }
    const store = await Database.getRdbStore();

    try{
      // 开始事务
      await store.beginTransaction();

      let totalDeleted = 0;
      for (const id of ids) {
        // 先清理资源
        const memo = await this.getById(id);

        // 执行删除
        const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
        predicates.equalTo('todo_id', id);
        const deleted = await store.delete(predicates);
        totalDeleted += deleted;
      }
      // 提交事务
      store.commit();

      return totalDeleted;
    }
    catch (e) {
      //
      // 回滚事务
      store.rollBack()
      console.error('Batch delete failed:', e);
      throw new Error('批量删除失败: ' + e.message);
    }


  }

  // 获取所有待办
  async getAll(): Promise<ITodoDetailModel[]> {
    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('modified_time');

    const columns = [
      'id', 'todo_id','title', 'priority', 'is_completed',
      'created_time', 'modified_time','due_time','location_name','latitude','longitude',
      'radius','memo'
    ];

    const result = await store.query(predicates, columns);
    return this.processResultSet(result);
  }

  // 获取置顶备忘录
  async getCompleted(): Promise<ITodoDetailModel[]> {
    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('is_completed', 1)
      .orderByDesc('modified_time');

    const result = await store.query(predicates);
    return this.processResultSet(result);
  }

  // 根据ID获取待办
  async getById(id: string): Promise<ITodoDetailModel | null> {
    const store = await Database.getRdbStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('todo_id', id);

    const result = await store.query(predicates);
    const todos = await this.processResultSet(result);
    return todos.length > 0 ? todos[0] : null;
  }

  // 处理查询结果集
  private async processResultSet(result: relationalStore.ResultSet): Promise<ITodoDetailModel[]> {
    const todos: ITodoDetailModel[] = [];

    while (result.goToNextRow()) {
      // const id = result.getLong(result.getColumnIndex('id'));
      const todoId = result.getString(result.getColumnIndex('todo_id'));
      const title = result.getString(result.getColumnIndex('title'));
      const isCompleted = result.getLong(result.getColumnIndex('is_completed')) === 1;
      const createdTime = result.getLong(result.getColumnIndex('created_time'));
      const modifiedTime = result.getLong(result.getColumnIndex('modified_time'));
      const dueTime = result.getLong(result.getColumnIndex('due_time'));
      const priority = result.getLong(result.getColumnIndex('priority'));
      const location_name = result.getString(result.getColumnIndex('location_name'));
      const latitude = result.getDouble(result.getColumnIndex('latitude'));
      const longitude = result.getDouble(result.getColumnIndex('longitude'));
      const radius = result.getLong(result.getColumnIndex('radius'));
      const memo = result.getString(result.getColumnIndex('memo'));



      todos.push({
        title,
        todoId,
        isCompleted,
        createdTime:formatDate(new Date(createdTime)),
        modifiedTime:formatDate(new Date(modifiedTime)),
        dueTime: dueTime?formatDate(new Date(dueTime)):undefined,
        priority,
        location: new LocationModel(location_name,latitude,longitude,radius),
        memo

      });
    }

    result.close();
    return todos;
  }

}

export default new TodoDao();