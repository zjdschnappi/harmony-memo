import { TodoItemSimpleModel } from "../model/Todo"
import { IItemNodeBuilderProp, IRectInfoInPx, ITransitionRouteParam } from "../types"
import { ComponentAttrUtils, RectInfoInPx } from "../utils/ComponentAttrUtils"
import { WindowUtils } from "../utils/WindowUtils"
import { deleteNode, ItemNode,createNode, getNode } from "./ItemNode"

export interface ICreateItemNodeBuilderProp extends IItemNodeBuilderProp<TodoItemSimpleModel> {
  onCheck?:(v:boolean)=>void
  onInput?:(v:string)=>void
}

@Builder
export function TodoItemBuilder(data: ICreateItemNodeBuilderProp) {
  // 跨容器迁移组件置于@Builder内
  TodoItemView({info:data.item, isExpand:data.isExpand,onCheck: data.onCheck, onInput: data.onInput}).id(data.item?data.item.id:null)
}

@ComponentV2
export struct TodoItemView {
  @Param @Require info: TodoItemSimpleModel|null
  @Param isExpand:boolean = false
  @Param onCheck:(v:boolean)=>void = ()=>{}
  @Param onInput:(v:string)=>void = ()=>{}
  @Param checkable:boolean = false

  build() {
    Row(){
      Checkbox()
        .select(this.info?.isCompleted)
        .onChange((v)=>{
          this.onCheck?.(v)
        })
        .enabled(!!this.info?.id)
      Column({space: 15}){
        TextInput({text:this.info?.title,placeholder:'待办事项'})
          .onChange((v)=>{
            this.onInput?.(v)
          })
          .fontColor(this.info?.isCompleted ? Color.Gray : Color.Black)
          .decoration({ type: this.info?.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
          .backgroundColor(Color.Transparent)
          .hitTestBehavior(this.isExpand?HitTestMode.Default:HitTestMode.None)
        if(this.info?.dueTime&&!this.isExpand){
          Text(this.info?.dueTime).fontSize(12)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 15 })

    }
    .width('100%')

  }
}



@ComponentV2
export struct TodoItem {
  @Param @Require info: TodoItemSimpleModel
  @Param onDetail:((item:ITransitionRouteParam)=>void)|null= null
  @Param checkable: boolean = false;
  @Param checked: boolean = false;
  @Param onCheck:(id:string,checked:boolean)=>void = ()=>{}
  @Local private todoItemNode: ItemNode<TodoItemSimpleModel> | undefined = new ItemNode(false)

  private wrapBuilder = wrapBuilder(TodoItemBuilder)

  private doFinishTransition(id:string){
    // MemoDetail结束转场时将节点从MemoDetail迁移回Home
    deleteNode(id)
    let data:ICreateItemNodeBuilderProp = {
      item: this.info,
      isExpand: false,
      onCheck:(v)=>{
        this.onCheck(this.info.todoId,v)
      }
    }
    this.todoItemNode = createNode(this.getUIContext(),data,this.wrapBuilder);
    this.todoItemNode?.update(false)
  }

  handleDetail(item:TodoItemSimpleModel){

    let itemRectInfo: RectInfoInPx =
      ComponentAttrUtils.getRectInfoById(WindowUtils.window.getUIContext(), item.id);
    let param:ITransitionRouteParam = {
      itemRectInfo:itemRectInfo as IRectInfoInPx,
      id:item.id,
      doDefaultTransition:() => {
        this.doFinishTransition(item.id)
      }
    }
    if(this.onDetail){

      this.onDetail?.(param)
      // 自定义节点从Home下树
      if (this.todoItemNode != undefined) {
        this.todoItemNode.onRemove();
      }
    }


  }
  aboutToAppear(): void {
    let node = getNode<TodoItemSimpleModel>(this.info.id);
    if (node == undefined) {
      // 新建自定义节点
      let data:ICreateItemNodeBuilderProp = {
        item:this.info,
        isExpand: false,
        onCheck:(v)=>{
          this.onCheck(this.info.todoId,v)
        }
      }
      node = createNode<TodoItemSimpleModel>(this.getUIContext(),data,this.wrapBuilder);
    }
    this.todoItemNode = node
  }
  build() {
    Row(){
      NodeContainer(this.todoItemNode).onClick(()=>{
        this.handleDetail(this.info)
      })
        .width('100%')
    }
    .backgroundColor(Color.White)
    .width('90%')
    .borderRadius(15)
    .padding({left: 15})
    .height(65)
  }
}

@Builder
export function endBuilder(onDelete:()=>void) {
  SymbolGlyph($r('sys.symbol.trash'))
    .fontSize(30)
    .margin({left: 15})
    .onClick(()=>{
      onDelete()
    })
}