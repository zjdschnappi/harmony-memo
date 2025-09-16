// 跨容器迁移能力
import { UIContext } from '@ohos.arkui.UIContext';
import { NodeController, BuilderNode, FrameNode } from '@ohos.arkui.node';
import { IItemNodeBuilderProp } from '../types';




export class ItemNode<T extends CommonNode = CommonNode> extends NodeController {
  private node: BuilderNode<IItemNodeBuilderProp<T>[]> | null = null;
  private isRemove: boolean = false;
  private builderData: IItemNodeBuilderProp<T>|null = null
  wrapBuilder?: WrappedBuilder<IItemNodeBuilderProp<T>[]>
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
      this.node = new BuilderNode<IItemNodeBuilderProp<T>[]>(uiContext);
      this.node.build(this.wrapBuilder)
    }
    if (this.node == null) {
      return null;
    }
    return this.node!.getFrameNode()!;
  }
  getNode(): BuilderNode<IItemNodeBuilderProp<T>[]> | null {
    return this.node;
  }

  setNode(node: BuilderNode<IItemNodeBuilderProp<T>[]> | null) {
    this.node = node;
    this.rebuild();
  }

  onRemove() {
    this.isRemove = true;
    this.rebuild();
    this.isRemove = false;
  }
  init(uiContext: UIContext, builderData:IItemNodeBuilderProp<T>,wrapBuilder?:WrappedBuilder<IItemNodeBuilderProp<T>[]>) {
    if (this.node != null) {
      return;
    }
    this.builderData = builderData
    this.wrapBuilder = wrapBuilder
    // 创建节点，需要uiContext
    this.node = new BuilderNode(uiContext)
    // 创建离线组件
    // this.node.build(this.wrapBuilder, { item: item, isExpand: isExpand })
    this.node.build(this.wrapBuilder, builderData)
  }

  update(isExpand: boolean,item?:T|null) {
    if (this.node !== null) {
      // 调用update进行更新。
      if(this.builderData){

        this.builderData.isExpand = isExpand
        if(item){
          this.builderData.item = item
        }
      }
      this.node.update(this.builderData);
    }
  }

}

interface CommonNode {
  id:string
}

let gNodeMap: Map<string, ItemNode<ESObject> | undefined> = new Map();

export const createNode =
  <T extends CommonNode>(uiContext: UIContext, builderData:IItemNodeBuilderProp<T> ,wrapBuilder?:WrappedBuilder<IItemNodeBuilderProp<T>[]>): ItemNode<T> | undefined => {
    let node:ItemNode<T> = new ItemNode(false);
    node.init(uiContext, builderData,wrapBuilder);
    if(builderData?.item?.id){
      gNodeMap.set(builderData.item.id, node);
    }
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