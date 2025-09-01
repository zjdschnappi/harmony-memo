import { MemoSimpleListItemModel } from '../model/Memo';
import { IMemoRouteParam,IRectInfoInPx } from '../types';
import { ComponentAttrUtils, RectInfoInPx } from '../utils/ComponentAttrUtils';
import { WindowUtils } from '../utils/WindowUtils';
import { createNode, getNode, MemoItemNode } from './MemoItemNode';

@Component
export struct MemoItem {
  @ObjectLink item:MemoSimpleListItemModel
  @State memoItemNode: MemoItemNode | undefined = new MemoItemNode(false)
  onDetail:((item:IMemoRouteParam)=>Promise<void>)|null= null

  private doFinishTransition(id:string): void {
    // PageTwo结束转场时将节点从PageTwo迁移回PageOne
    this.memoItemNode = getNode(id);
    this.memoItemNode?.update(false)
  }

  handleDetail(item:MemoSimpleListItemModel){

    let itemRectInfo: RectInfoInPx =
      ComponentAttrUtils.getRectInfoById(WindowUtils.window.getUIContext(), item.memoId);
    let param:IMemoRouteParam = {
      itemRectInfo:itemRectInfo as IRectInfoInPx,
      id:item.memoId,
      doDefaultTransition:() => {
        this.doFinishTransition(item.memoId)
      }
    }

   this.onDetail?.(param).then(()=>{
     // 自定义节点从Home下树
     if (this.memoItemNode != undefined) {
       this.memoItemNode.onRemove();
     }
   })

  }
  aboutToAppear(): void {
    let node = getNode(this.item.memoId);
    if (node == undefined) {
      // 新建自定义节点
      node = createNode(this.getUIContext(),this.item,false);
    }
    this.memoItemNode = node
  }
  build() {
    Column(){
      NodeContainer(this.memoItemNode).onClick(()=>{
        this.handleDetail(this.item)
      })
    }
  }
}