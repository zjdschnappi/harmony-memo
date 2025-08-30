import { CustomTransition } from '../customTransition/CustomNavigationUtils';
import { getNode, MemoItemNode } from '../components/MemoItemNode'
import { AnimationProperties } from '../customTransition/AnimationProperties'
import {IMemoRouteParam} from '../types'
import { RectInfoInPx } from '../utils/ComponentAttrUtils'

@Builder
function MemoDetailBuilder(){
  MemoDetail()
}

@Component
struct MemoDetail {
  pageInfos:NavPathStack = new NavPathStack()
  @State AnimationProperties: AnimationProperties = new AnimationProperties(this.getUIContext());
  @State myNodeController: MemoItemNode | undefined = new MemoItemNode(false);

  private pageId: number = -1;

  private shouldDoDefaultTransition: boolean = false;
  private prePageDoFinishTransition: (() => void) = () => {};
  private itemRectInfo: RectInfoInPx = new RectInfoInPx();

  @StorageProp('windowSizeChanged') @Watch('unRegisterNavParam') windowSizeChangedTime: number = 0;
  @StorageProp('onConfigurationUpdate') @Watch('unRegisterNavParam') onConfigurationUpdateTime: number = 0;


  private unRegisterNavParam(): void {
    this.shouldDoDefaultTransition = true;
  }

  private onBackPressed(): boolean {
    if (this.shouldDoDefaultTransition) {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);
      this.pageInfos.pop();
      this.prePageDoFinishTransition();
      this.shouldDoDefaultTransition = false;
      return true;
    }
    this.pageInfos.pop();
    return true;
  }

  build() {
    NavDestination() {
      Stack(){
        Stack(){
          Column() {
            NodeContainer(this.myNodeController)
          }
          .alignItems(HorizontalAlign.Start)
        }.position({y:this.AnimationProperties.positionValue})
      }
      .scale({ x: this.AnimationProperties.scaleValue, y: this.AnimationProperties.scaleValue })
      .translate({ x: this.AnimationProperties.translateX, y: this.AnimationProperties.translateY })
      .width(this.AnimationProperties.clipWidth)
      .height(this.AnimationProperties.clipHeight)
      .borderRadius(this.AnimationProperties.radius)
      // expandSafeArea使得Stack做沉浸式效果，向上扩到状态栏，向下扩到导航条
      .expandSafeArea([SafeAreaType.SYSTEM])
      .backgroundColor(this.AnimationProperties.navDestinationBgColor)

    }
    .backgroundColor(Color.Transparent)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.pageId = this.pageInfos.getAllPathName().length - 1;

      let param = context.pathInfo?.param as IMemoRouteParam;
      this.myNodeController = getNode(param.id);
      this.myNodeController?.update(true)
      let noop = ()=>{}
      this.prePageDoFinishTransition = param.doDefaultTransition||noop
      this.itemRectInfo = param.itemRectInfo as RectInfoInPx
      CustomTransition.getInstance().registerNavParam(this.pageId,
        (isPush: boolean, isExit: boolean, transitionProxy: NavigationTransitionProxy) => {
          this.AnimationProperties.doAnimation(
            this.itemRectInfo, isPush, isExit, transitionProxy, 0,
            this.prePageDoFinishTransition, this.myNodeController);
        }, 500);
    })
    .onBackPressed(() => {
      return this.onBackPressed();
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);
    })
  }
}