import { emitter, Callback } from '@kit.BasicServicesKit';

// 第一步：定义事件类型常量。这是关键，用有意义的字符串代替数字，方便管理！
export enum EventTypes  {
  FETCH_MEMO_LIST = 0, // 备忘录列表
  FETCH_MEMO_DETAIL = 1, // 备忘录详情
  // ---------------

  EDITOR_SELECTION_CHANGE= 3 //编辑器内选区范围

  // ... 其他事件根据需要继续添加
}

// 第二步：创建 EventBus 类
class EventManager {
  // 订阅事件
  on(eventType: EventTypes, callback:Callback<emitter.EventData>) {
    const subscribeEvent: emitter.InnerEvent = {
      eventId: eventType // 直接用字符串作为事件ID
    };
    emitter.on(subscribeEvent, callback);
  }

  // 函数实现
  emit(eventType: EventTypes, data?: emitter.EventData) {
    const emitEvent:emitter.InnerEvent  = {
      eventId: eventType
    };
    const eventData:emitter.EventData = {
      data: data // 将数据放在 data 字段下
    };
    emitter.emit(emitEvent, eventData);
  }

  // 取消订阅特定事件
  off(eventType: EventTypes) {
    emitter.off(eventType);
  }
}

// 第三步：导出一个全局唯一的实例
export default new EventManager();