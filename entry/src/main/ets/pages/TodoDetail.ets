import { CustomTransition } from '../customTransition/CustomNavigationUtils';
import { getNode, ItemNode } from '../components/ItemNode'
import { AnimationProperties } from '../customTransition/AnimationProperties'
import { ITransitionRouteParam } from '../types'
import { RectInfoInPx } from '../utils/ComponentAttrUtils'
import { CustomTitleBar } from '../components/CustomTitleBar';
import { SharePanel } from '../components/SharePanel';
import EventManager, { EventTypes } from '../utils/EventManager';
import { TodoCreateFormView } from '../components/TodoCreateFormView';

@Builder
function TodoDetailBuilder(){
  TodoDetail()
}

@Component
struct TodoDetail {
  pageInfos:NavPathStack = new NavPathStack()
  @State AnimationProperties: AnimationProperties = new AnimationProperties(this.getUIContext());
  @State myNodeController: ItemNode | undefined = new ItemNode(false);
  private pageId: number = -1;
  private pageParams:ITransitionRouteParam = {id:'-1'}
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
  private handleDelete(){
    //
    this.getUIContext().getPromptAction().showDialog({
      title: '提示',
      message:'确认删除这条记录吗？',
      buttons:[
        {text:'取消',primary:false,color:'black'},
        {text:'确定',primary:true,color:'red'}
      ],

    }).then((value)=>{
      if(value.index==1) {
        //
        //
        //
      }else {
      }
    })

  }
  private handleEdit(){
    //
    let params:ITransitionRouteParam = {id:this.pageParams.id}
    this.pageInfos.pushPathByName('CreateMemo',params,false)
  }
  private handleBack = () =>{
    this.onBackPressed()
  }
  build() {
    NavDestination() {
      Stack({alignContent:Alignment.Start}){
        Stack({alignContent:Alignment.Start}){
          Column() {
            CustomTitleBar({onBackPress:this.handleBack})

              .padding({left: 15,right: 15})
            // NodeContainer(this.myNodeController)
            if(this.AnimationProperties.showDetailContent){
              TodoCreateFormView({
                onSubmit:()=>{
                  return Promise.resolve('1')
                }
              })
              Row(){
                SharePanel({targetViewComponentId:''})
                SymbolGlyph($r('sys.symbol.trash')).fontSize(30).onClick(()=>{
                  this.handleDelete()
                })
              }
              .justifyContent(FlexAlign.SpaceAround)
              .width('100%')
            }
          }
          .alignItems(HorizontalAlign.Start)

        }

        // .position({y:this.AnimationProperties.positionValue})

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

      let param = context.pathInfo?.param as ITransitionRouteParam;
      this.pageParams = param
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