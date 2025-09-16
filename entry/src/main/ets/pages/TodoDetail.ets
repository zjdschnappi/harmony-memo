import { CustomTransition } from '../customTransition/CustomNavigationUtils';
import { getNode, ItemNode } from '../components/ItemNode'
import { AnimationProperties } from '../customTransition/AnimationProperties'
import { ITransitionRouteParam } from '../types'
import { RectInfoInPx } from '../utils/ComponentAttrUtils'
import { SharePanel } from '../components/SharePanel';
import { TodoCreateFormView } from '../components/TodoCreateFormView';
import TodoViewModel from '../viewmodel/TodoViewModel'
import EventManager, { EventTypes } from '../utils/EventManager'
import { ITodoDetailModel } from '../model/Todo';

@Builder
function TodoDetailBuilder(){
  TodoDetail()
}

@ComponentV2
struct TodoDetail {
  pageInfos:NavPathStack = new NavPathStack()
  @Local AnimationProperties: AnimationProperties = new AnimationProperties(this.getUIContext());
  @Local myNodeController: ItemNode | undefined = new ItemNode(false);
  @Local detailData: ITodoDetailModel|null = null
  private pageId: number = -1;
  private pageParams:ITransitionRouteParam = {id:'-1'}
  private shouldDoDefaultTransition: boolean = false;
  private prePageDoFinishTransition: (() => void) = () => {};
  private itemRectInfo: RectInfoInPx = new RectInfoInPx();

  // todo v2版不支持StorageProp
  // @StorageProp('windowSizeChanged') @Watch('unRegisterNavParam') windowSizeChangedTime: number = 0;
  // @StorageProp('onConfigurationUpdate') @Watch('unRegisterNavParam') onConfigurationUpdateTime: number = 0;


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
        let id = this.detailData?.todoId!
        TodoViewModel.delete([id]).then(()=>{
          EventManager.emit(EventTypes.FETCH_TODO_LIST)
          this.handleBack()
        })
        //
        //
      }else {
      }
    })

  }
  private handleBack = () =>{
    this.onBackPressed()
  }
  private handleGetDetail=(id:string)=>{
    TodoViewModel.getDetailById(id).then(data=>{
        this.detailData = data
    })
  }

  build() {
    NavDestination() {
      Stack({alignContent:Alignment.Start}){
        Stack({alignContent:Alignment.Start}){
          Column() {

            if(this.AnimationProperties.showDetailContent){
              TodoCreateFormView(
                {
                  detailData: this.detailData,
                  sheetTitle: '待办详情',
                  onCancel:()=>{
                    this.handleBack()
                  },
                  onSubmitSuccess:()=>{
                    this.handleBack()
                  }
                }
              ).layoutWeight(1)
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

      this.handleGetDetail(param.id)
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