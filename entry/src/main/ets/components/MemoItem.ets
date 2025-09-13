import { MemoSimpleListItemModel } from '../model/Memo';
import { IItemNodeBuilderProp, ITransitionRouteParam,IRectInfoInPx } from '../types';
import { ComponentAttrUtils, RectInfoInPx } from '../utils/ComponentAttrUtils';
import { WindowUtils } from '../utils/WindowUtils';
import { createNode, deleteNode, getNode, ItemNode } from './ItemNode';
import { MemoItemView } from './MemoItemView';


@Builder
export function MemoItemBuilder(data: IItemNodeBuilderProp<MemoSimpleListItemModel>) {
  // 跨容器迁移组件置于@Builder内
  MemoItemView({item:data.item, isExpand:data.isExpand}).id(data.item.memoId)
}

@ComponentV2
export struct MemoItem {
  @Param @Require item:MemoSimpleListItemModel
  @Local memoItemNode: ItemNode<MemoSimpleListItemModel> | undefined = new ItemNode(false)
  @Param onDetail:((item:ITransitionRouteParam)=>void)|null= null
  @Param checkable: boolean = false;
  @Param checked: boolean = false;
  @Param onCheck:(id:string,checked:boolean)=>void = ()=>{}

  private wrapBuilder = wrapBuilder(MemoItemBuilder)

  private doFinishTransition(id:string){
    // MemoDetail结束转场时将节点从MemoDetail迁移回Home
    deleteNode(id)
    this.memoItemNode = createNode(this.getUIContext(),this.item,false,this.wrapBuilder);
    this.memoItemNode?.update(false)
  }

  handleDetail(item:MemoSimpleListItemModel){

    let itemRectInfo: RectInfoInPx =
      ComponentAttrUtils.getRectInfoById(WindowUtils.window.getUIContext(), item.memoId);
    let param:ITransitionRouteParam = {
      itemRectInfo:itemRectInfo as IRectInfoInPx,
      id:item.memoId,
      doDefaultTransition:() => {
        this.doFinishTransition(item.memoId)
      }
    }
    if(this.onDetail){

       this.onDetail?.(param)
       // 自定义节点从Home下树
       if (this.memoItemNode != undefined) {
         this.memoItemNode.onRemove();
       }
    }


  }
  aboutToAppear(): void {
    let node = getNode<MemoSimpleListItemModel>(this.item.memoId);
    if (node == undefined) {
      // 新建自定义节点
      node = createNode<MemoSimpleListItemModel>(this.getUIContext(),this.item, false,this.wrapBuilder);
    }
    this.memoItemNode = node
  }
  build() {
    Row(){
      if(this.checkable){
        Checkbox()
          .select(this.checked)
          .onChange((v)=>{
            this.onCheck(this.item.memoId,v)
          })
      }
      if(this.item.isPinned){
        Text('置顶')
          .borderRadius({
            topLeft: 15
          })
          .backgroundColor(Color.Green)
          .padding({left:5,right:5})
          .position({left:0,top:0})
          .fontColor(Color.White).fontSize(12)
      }
      NodeContainer(this.memoItemNode).onClick(()=>{
        this.handleDetail(this.item)
      })
        .layoutWeight(1)
    }
    .borderRadius(15)
    .width('90%')
    .backgroundColor(Color.White)
  }
}