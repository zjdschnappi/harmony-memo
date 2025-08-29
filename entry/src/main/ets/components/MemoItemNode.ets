// 跨容器迁移能力
import { UIContext } from '@ohos.arkui.UIContext';
import { NodeController, BuilderNode, FrameNode } from '@ohos.arkui.node';
import { MemoItemView } from './MemoItemView'
import { MemoSimpleListItemModel } from '../model/Memo';

interface IBuilderProp {
  item: MemoSimpleListItemModel;
  isExpand?:boolean
}

@Builder
function MemoItemBuilder(data: IBuilderProp) {
  // 跨容器迁移组件置于@Builder内
  MemoItemView({item:data.item,isExpand:data.isExpand}).id(data.item.memoId)
}


export class MemoItemNode extends NodeController {
  private node: BuilderNode<IBuilderProp[]> | null = null;
  private isRemove: boolean = false;
  private item: MemoSimpleListItemModel|null = null
  private wrapBuilder: WrappedBuilder<IBuilderProp[]> = wrapBuilder(MemoItemBuilder);
  private needCreate: boolean = false;
  constructor(create: boolean) {
    super();
    this.needCreate = create;
  }
  makeNode(uiContext: UIContext): FrameNode | null {
    if(this.isRemove == true){
      return null;
    }
    if (this.needCreate && this.node == null) {
      this.node = new BuilderNode<IBuilderProp[]>(uiContext);
      this.node.build(this.wrapBuilder)
    }
    if (this.node == null) {
      return null;
    }
    return this.node!.getFrameNode()!;
  }
  getNode(): BuilderNode<IBuilderProp[]> | null {
    return this.node;
  }

  setNode(node: BuilderNode<IBuilderProp[]> | null) {
    this.node = node;
    this.rebuild();
  }

  onRemove() {
    this.isRemove = true;
    this.rebuild();
    this.isRemove = false;
  }
  init(uiContext: UIContext, item: MemoSimpleListItemModel, isExpand: boolean) {
    if (this.node != null) {
      return;
    }
    this.item = item
    // 创建节点，需要uiContext
    this.node = new BuilderNode(uiContext)
    // 创建离线组件
    this.node.build(this.wrapBuilder, { item: item, isExpand: isExpand })
  }

  update(isExpand: boolean) {
    if (this.node !== null) {
      // 调用update进行更新。
      this.node.update({ item: this.item, isExpand: isExpand });
    }
  }

}

let gNodeMap: Map<string, MemoItemNode | undefined> = new Map();

export const createNode =
  (uiContext: UIContext, item: MemoSimpleListItemModel, isExpand: boolean): MemoItemNode | undefined => {
    let node = new MemoItemNode(false);
    node.init(uiContext, item, isExpand);
    gNodeMap.set(item.memoId, node);
    return node;
  }

export const getNode = (id: string): MemoItemNode | undefined => {
  if (!gNodeMap.has(id)) {
    return undefined
  }
  return gNodeMap.get(id);
}

export const deleteNode = (id: string) => {
  gNodeMap.delete(id)
}