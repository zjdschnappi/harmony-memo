import { KeyboardAvoidMode } from "@ohos.arkui.UIContext";
import MemoViewModel from '../viewmodel/MemoViewModel'
import { IMemoRouteParam,  } from "../types";
import { IMemoContentItem } from "../model/Memo";
import { Editor } from "../components/Editor";
import { MemoDetailView } from "../components/MemoDetailView";
import { CustomTitleBar } from "../components/CustomTitleBar";

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

  @Builder
  titleBarBuilder(){
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
    this.pageInfos.popToName('Home',{result:null})
  }
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)

  }
  build() {
    //
    NavDestination(){
      CustomTitleBar({
        onBackPress:()=>{
          this.pageInfos.pop()
        },
        extraContent:()=>{
          this.titleBarBuilder()
        }
      })
        .padding({left:15,right:15})
      MemoDetailView({memoTitle:this.memoTitle})
      .width('100%').layoutWeight(1)
    }
    .systemTransition(NavigationSystemTransitionType.NONE)
    .onReady((ctx)=>{

      this.pageInfos = ctx.pathStack
      this.pageParams = ctx.pathInfo.param as IMemoRouteParam

    })
    .height('100%')
    .hideTitleBar(true)

  }
}