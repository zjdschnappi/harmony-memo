import { TodoItemSimpleModel } from "../model/Todo"
import { ITransitionRouteParam } from "../types"
import { formatDate } from "../utils/DateUtil"
import { TodoCreateFormView } from "./TodoCreateFormView"
import { endBuilder, TodoItem } from "./TodoItem"
import TodoViewModel from '../viewmodel/TodoViewModel'
import EventManager, { EventTypes } from '../utils/EventManager'

interface IParam {
  item: TodoItemSimpleModel;
  index:number
}
function syncArrays(oldArray:TodoItemSimpleModel[], newArray:TodoItemSimpleModel[]) {
  // 创建ID映射以便快速查找
  const oldMap = new Map<string,IParam>();
  oldArray.forEach((item, index) => oldMap.set(item.todoId, { item, index }));

  const newMap = new Map<string,TodoItemSimpleModel>();
  newArray.forEach(item => newMap.set(item.todoId, item));

  // 找出需要移除的数据（在旧数组但不在新数组中）
  const toRemove:number[] = [];
  for (let i = oldArray.length - 1; i >= 0; i--) {
    if (!newMap.has(oldArray[i].todoId)) {
      toRemove.push(i);
    }
  }

  // 从后往前删除，避免索引变化问题
  toRemove.forEach(index => {
    oldArray.splice(index, 1);
  });

  // 更新和新增数据
  newArray.forEach(newItem => {
    const oldEntry = oldMap.get(newItem.todoId);

    if (oldEntry) {
      // 更新现有项
      const oldItem = oldEntry.item;
      oldItem.title = newItem.title
      oldItem.memo = newItem.memo
      oldItem.modifiedTime = newItem.modifiedTime
      oldItem.isCompleted = newItem.isCompleted
      oldItem.location = newItem.location
      oldItem.dueTime = newItem.dueTime
      oldItem.priority = newItem.priority

    } else {
      // 新增项
      oldArray.push(new TodoItemSimpleModel(
        newItem.id,
        newItem.todoId,
        newItem.title,
        newItem.createdTime,
        newItem.modifiedTime,
        newItem.isCompleted,
        newItem.priority,
        newItem.dueTime,
        newItem.location,
        newItem.memo
      ));
    }
  });
}

@ComponentV2
export default struct TodoView {
  @Consumer() pagePathStackInfos:NavPathStack = new NavPathStack()
  @Local private list: TodoItemSimpleModel[] = []
  @Local private sheetOpen:boolean = false

  @Builder
  sheetContentBuilder(){
    Column(){
      TodoCreateFormView({
        onCancel:()=>{
          this.sheetOpen = false
        },
        onSubmitSuccess:()=>{
          this.sheetOpen = false
        }
      })
    }
  }

  private handleDetail = (param:ITransitionRouteParam)=>{
    this.pagePathStackInfos.pushPathByName('TodoDetail',param)
  }
  private handleCheck = (id:string,checked:boolean)=>{
    TodoViewModel.toggleCompleted(id,checked).then(()=>{
      let index = this.list.findIndex(item=>item.todoId==id)
      if(index>-1){
        this.list[index].isCompleted = checked
      }
    })
  }
  private getTodoList=()=>{
    TodoViewModel.getTodos().then(data=>{
      syncArrays(this.list,data)
    })
  }

  aboutToAppear(){
    this.getTodoList()
    EventManager.on(EventTypes.FETCH_TODO_LIST,()=>{
      this.getTodoList()
    })
  }
  build(){
    //
    Column(){

      if(this.list.length){
        List({space: 15}){
          ForEach(this.list,(item:TodoItemSimpleModel)=>{
            ListItem(){
              TodoItem({
                info: item,
                onDetail:this.handleDetail,
                onCheck:this.handleCheck
              })
            }
            .swipeAction({
              end: endBuilder(item)
            })
          },(item:TodoItemSimpleModel)=>{
            return item.todoId
          })
        }
        .height('100%')
        .margin({top: 15})
        .alignListItem(ListItemAlign.Center)
      }else {
        Text('暂无数据')
      }

      Row(){
        SymbolGlyph($r('sys.symbol.plus_circle'))
          .fontSize(30)
          .onClick(()=>{
            this.sheetOpen = true
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .position({bottom:20,left:0,right:0})
    }
    .bindSheet($$this.sheetOpen,this.sheetContentBuilder(),{
      height: SheetSize.LARGE,
      backgroundColor: '#f3f3f3',
      showClose: false

    })
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')

  }
}