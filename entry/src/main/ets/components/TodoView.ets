import { TodoItemSimpleModel } from "../model/Todo"
import { ITransitionRouteParam } from "../types"
import { formatDate } from "../utils/DateUtil"
import { TodoCreate } from "./TodoCreateFormView"
import { endBuilder, TodoItem } from "./TodoItem"

let id = 0
@ComponentV2
export default struct TodoView {
  @Consumer() pagePathStackInfos:NavPathStack = new NavPathStack()
  @Local private list: TodoItemSimpleModel[] = []
  @Local private sheetOpen:boolean = false

  @Builder
  sheetContentBuilder(){
    Column(){
      TodoCreate({
        onSubmit: this.handleSubmit
      })
    }
  }
  private handleSubmit= async (title:string,time:string|null,memo?:string)=>{
    let p = new Promise<string>((resolve,reject)=>{
      let newId = String(id++)
      this.list.push(
        new TodoItemSimpleModel(newId,title,formatDate(new Date()),formatDate(new Date()),false,time,undefined,memo)
      )
      this.sheetOpen = false
      resolve(newId)
    })
    return p

  }
  private handleDetail = (param:ITransitionRouteParam)=>{
    this.pagePathStackInfos.pushPathByName('TodoDetail',param)
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
                onDetail:this.handleDetail
              })
            }
            .swipeAction({
              end: endBuilder(item)
            })
          },(item:TodoItemSimpleModel)=>{
            return item.id
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
      title: {
        title: '新建待办'
      }

    })
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')

  }
}