// 跨容器迁移能力
import { UIContext } from '@ohos.arkui.UIContext';
import { NodeController, BuilderNode, FrameNode } from '@ohos.arkui.node';


interface IBuilderProp<T> {
  item: T;
  isExpand?:boolean
}



export class ItemNode<T extends CommonNode = CommonNode> extends NodeController {
  private node: BuilderNode<IBuilderProp<T>[]> | null = null;
  private isRemove: boolean = false;
  private item: T|null = null
  wrapBuilder?: WrappedBuilder<IBuilderProp<T>[]>
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
      this.node = new BuilderNode<IBuilderProp<T>[]>(uiContext);
      this.node.build(this.wrapBuilder)
    }
    if (this.node == null) {
      return null;
    }
    return this.node!.getFrameNode()!;
  }
  getNode(): BuilderNode<IBuilderProp<T>[]> | null {
    return this.node;
  }

  setNode(node: BuilderNode<IBuilderProp<T>[]> | null) {
    this.node = node;
    this.rebuild();
  }

  onRemove() {
    this.isRemove = true;
    this.rebuild();
    this.isRemove = false;
  }
  init(uiContext: UIContext, item: T, isExpand: boolean,wrapBuilder?:WrappedBuilder<IBuilderProp<T>[]>) {
    if (this.node != null) {
      return;
    }
    this.item = item
    this.wrapBuilder = wrapBuilder
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

interface CommonNode {
  id:string
}

let gNodeMap: Map<string, ItemNode<ESObject> | undefined> = new Map();

export const createNode =
  <T extends CommonNode>(uiContext: UIContext, item: T, isExpand: boolean,wrapBuilder?:WrappedBuilder<IBuilderProp<T>[]>): ItemNode<T> | undefined => {
    let node:ItemNode<T> = new ItemNode(false);
    node.init(uiContext, item, isExpand,wrapBuilder);
    gNodeMap.set(item.id, node);
    return node;
  }

export const getNode = <T extends CommonNode>(id: string): ItemNode<T> | undefined => {
  if (!gNodeMap.has(id)) {
    return undefined
  }
  return gNodeMap.get(id);
}

export const deleteNode = (id: string) => {
  gNodeMap.delete(id)
}