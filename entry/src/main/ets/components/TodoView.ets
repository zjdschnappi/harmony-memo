import { TodoItemSimpleModel } from "../model/Todo"
import { formatDate } from "../utils/DateUtil"
import { TodoCreate } from "./TodoCreate"
import { endBuilder, TodoItem } from "./TodoItem"

@ComponentV2
export default struct TodoView {
  @Local list: TodoItemSimpleModel[] = [
    new TodoItemSimpleModel('1','待办1',formatDate(new Date()),formatDate(new Date()),false)
  ]
  @Local sheetOpen:boolean = false

  @Builder
  sheetContentBuilder(){
    Column(){
      TodoCreate()
    }
  }
  build(){
    //
    Column(){

      if(this.list.length){
        List({space: 15}){
          ForEach(this.list,(item:TodoItemSimpleModel)=>{
            ListItem(){
              TodoItem({
                info: item
              })
            }
            .swipeAction({
              end: endBuilder(item)
            })
          },(item:TodoItemSimpleModel)=>{
            return item.id
          })
        }
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
      title: {
        title: '新建待办'
      }

    })
    .width('100%')
    .height('100%')

  }
}