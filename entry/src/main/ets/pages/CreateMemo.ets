import { KeyboardAvoidMode } from "@ohos.arkui.UIContext";
import MemoViewModel from '../viewmodel/MemoViewModel'
import { IMemoRouteParam,  } from "../types";
import { IMemoContentItem } from "../model/Memo";
import { Editor } from "../components/Editor";
import { MemoDetailView } from "../components/MemoDetailView";

@Builder
export function CreateMemoBuilder(){
  CreateMemo()
}

@Extend(Text)
function IconText(enabled:boolean = true){
  .fontSize(26)
  .width(40)
  .height(40)
  .enabled(enabled)
  .opacity(enabled?1:0.1)
  .backgroundColor('#dfdfdf')
  .borderRadius('50%')
  .textAlign(TextAlign.Center)
}


@Preview
@Component
struct CreateMemo {
  pageInfos:NavPathStack = new NavPathStack()
  controller: RichEditorController = new RichEditorController();
  pageParams:IMemoRouteParam ={id:'-1'}
  @State memoTitle:string = '标题'
  @State translateY: string = '0';

  async handleSubmit(){
    //
    let title = this.memoTitle;
    let spans = this.controller.getSpans();

    let memoId = this.pageParams.id

    if(memoId == '-1'){
      await MemoViewModel.createMemo(title,spans)

    }else {
     //
      await MemoViewModel.updateMemo(memoId,title,spans)
    }
    this.pageInfos.pop({result:null})
  }
  handleGetDetail(){
    let px2vp = this.getUIContext().px2vp
    MemoViewModel.getDetailById(this.pageParams.id).then((data)=>{

      this.memoTitle = data?.title||''
      data?.content?.forEach((item:IMemoContentItem)=>{
        if(typeof (item as RichEditorImageSpanResult).valueResourceStr!='undefined'){
          let content = item as RichEditorImageSpanResult

          this.controller.addImageSpan(content.valueResourceStr,{
            imageStyle: {
              size:content.imageStyle.size.map(item=>px2vp(item)) as [Dimension,Dimension],
              layoutStyle:content.imageStyle.layoutStyle,
              verticalAlign:content.imageStyle.verticalAlign,
              objectFit:content.imageStyle.objectFit
            }
          })
        }else {
          let content = item as RichEditorTextSpanResult
          this.controller.addTextSpan(content.value,{
            style: {
              fontColor: content.textStyle.fontColor,
              fontWeight: content.textStyle.fontWeight==9?FontWeight.Bold:FontWeight.Normal,
              fontSize: content.textStyle.fontSize,
              fontStyle: content.textStyle.fontStyle,
              decoration: content.textStyle.decoration,
              fontFeature: content.textStyle.fontFeature

            },
            paragraphStyle: content.paragraphStyle
          })
        }
      })
    })
  }
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)

  }
  build() {
    //
    NavDestination(){
      Row(){
        Text(){
          SymbolSpan($r('sys.symbol.chevron_left'))

        }
        .IconText()
        .onClick(()=>{
          this.pageInfos.popToIndex(-1)
        })
        Row({space: 10}){
          Text(){
            SymbolSpan($r('sys.symbol.undo'))
          }.IconText(false)
          Text(){
            SymbolSpan($r('sys.symbol.redo'))
          }.IconText(false)
          Text(){
            SymbolSpan($r('sys.symbol.checkmark'))
          }.IconText(true).onClick(()=>{
            this.handleSubmit()
          })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({left:15,right:15})
      .margin({top: 10})
      .width('100%')
      .height(50)
      MemoDetailView()
      .width('100%').layoutWeight(1)
    }
    .translate({ y: this.translateY })
    .customTransition(
      (op: NavigationOperation, isEnter: boolean)
        : Array<NavDestinationTransition> | undefined => {
        console.log('[NavDestinationTransition]', 'reached delegate in frontend, op: ' + op + ', isEnter: ' + isEnter);
        // navDestination动画的事件。navDestination自定义动画会基于当前组件的UI状态与事件执行后的UI状态来发起动画。
        let transitionOneEvent = () => { console.log('[NavDestinationTransition]', 'reached transitionOne, empty now!'); }
        if (op === NavigationOperation.PUSH) {
          if (isEnter) {
            // ENTER_PUSH
            // 为入场的PUSH页面设置动画
            console.log('[NavDestinationTransition]', 'push & isEnter, init y to 100%');
            this.translateY = '100%';
            transitionOneEvent = () => {
              console.log('[NavDestinationTransition]', 'push & isEnter, finally set y to 0');
              this.translateY = '0';
            }
          }
        } else if (op === NavigationOperation.POP) {
          if (!isEnter) {
            // EXIT_POP
            // 为离场的POP页面设置动画
            console.log('[NavDestinationTransition]', 'pop & isExit, init y to 0');
            this.translateY = '0';
            transitionOneEvent = () => {
              console.log('[NavDestinationTransition]', 'pop & isExit, finally set y to 100%');
              this.translateY = '100%';
            }
          }
        } else if (op === NavigationOperation.REPLACE) {
          console.log('[NavDestinationTransition]', 'REPLACE not support');
        } else {
          console.log('[NavDestinationTransition]', 'invalid operation!');
        }
        // 根据以上逻辑，确定动画的行为，并创建类型为NavDestinationTransition的动画实例transitionOne
        let transitionOne: NavDestinationTransition = {
          duration: 500,
          delay: 0,
          curve: Curve.Friction,
          event: transitionOneEvent,
          onTransitionEnd: () => { console.log('[NavDestinationTransition]', 'reached transitionOneFinish, empty now!'); }
        };
        // 将transitionOne作为返回值传递给系统，系统侧将发起transitionOne对应的动画
        return [ transitionOne ];
      })
    .onReady((ctx)=>{

      this.pageInfos = ctx.pathStack
      this.pageParams = ctx.pathInfo.param as IMemoRouteParam

      this.handleGetDetail()
    })
    .height('100%')
    .hideTitleBar(true)
  }
}