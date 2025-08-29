import { MemoSimpleListItemModel } from '../model/Memo';
import { ComponentAttrUtils, RectInfoInPx } from '../utils/ComponentAttrUtils';
import { WindowUtils } from '../utils/WindowUtils';
import { createNode, getNode, MemoItemNode } from './MemoItemNode';

@Component
export struct MemoItem {
  @ObjectLink item:MemoSimpleListItemModel
  @State memoItemNode: MemoItemNode | undefined = new MemoItemNode(false)
  pageInfos: NavPathStack = new NavPathStack();

  private doFinishTransition(id:string): void {
    // PageTwo结束转场时将节点从PageTwo迁移回PageOne
    this.memoItemNode = getNode(id);
    this.memoItemNode?.update(false)
  }

  handleDetail(item:MemoSimpleListItemModel){

    let itemRectInfo: RectInfoInPx =
      ComponentAttrUtils.getRectInfoById(WindowUtils.window.getUIContext(), item.memoId);
    let param: Record<string, Object> = {};
    param['itemRectInfo'] = itemRectInfo;
    param['id'] = item.memoId
    param['doDefaultTransition'] = (myController: MemoItemNode) => {
      this.doFinishTransition(item.memoId)
    };
    this.pageInfos.pushPathByName('MemoDetail',param);
    // 自定义节点从Home下树
    if (this.memoItemNode != undefined) {
      this.memoItemNode.onRemove();
    }
  }
  aboutToAppear(): void {
    let node = getNode(this.item.memoId);
    if (node == undefined) {
      // 新建自定义节点
      node = createNode(this.getUIContext(),this.item,false);
    }
    this.memoItemNode = getNode(this.item.memoId);
  }
  build() {
    Column(){
      NodeContainer(this.memoItemNode).onClick(()=>{
        this.handleDetail(this.item)
      })
    }
  }
}