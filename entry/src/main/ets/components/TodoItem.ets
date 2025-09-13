import { TodoItemSimpleModel } from "../model/Todo"
import { IItemNodeBuilderProp, IRectInfoInPx, ITransitionRouteParam } from "../types"
import { ComponentAttrUtils, RectInfoInPx } from "../utils/ComponentAttrUtils"
import { WindowUtils } from "../utils/WindowUtils"
import { deleteNode, ItemNode,createNode, getNode } from "./ItemNode"

@Builder
export function TodoItemBuilder(data: IItemNodeBuilderProp<TodoItemSimpleModel>) {
  // 跨容器迁移组件置于@Builder内
  TodoItemView({info:data.item, isExpand:data.isExpand}).id(data.item.id)
}

@ComponentV2
struct TodoItemView {
  @Param @Require info: TodoItemSimpleModel
  @Param isExpand:boolean = false
  @Param onCheck:(v:boolean)=>void = ()=>{}
  build() {
    Row(){
      Checkbox()
        .select($$this.info.isCompleted)
        .onChange((v)=>{
          this.onCheck(v)
        })
      Column({space: 15}){
        Text(this.info.title)
          .fontColor(this.info.isCompleted ? Color.Gray : Color.Black)
          .decoration({ type: this.info.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
        if(this.info.dueTime){
          Text(this.info.dueTime).fontSize(12)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 15 })

    }

    .padding({top: 20,bottom:20,left: 15,right: 15})
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
    this.todoItemNode = createNode(this.getUIContext(),this.info,false,this.wrapBuilder);
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
      node = createNode<TodoItemSimpleModel>(this.getUIContext(),this.info, false,this.wrapBuilder);
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

  }
}

@Builder
export function endBuilder(item: TodoItemSimpleModel) {
  SymbolGlyph($r('sys.symbol.trash'))
    .fontSize(30)
    .margin({left: 15})
}