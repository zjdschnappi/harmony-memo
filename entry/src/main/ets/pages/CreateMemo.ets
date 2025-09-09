import { KeyboardAvoidMode } from "@ohos.arkui.UIContext";
import MemoViewModel from '../viewmodel/MemoViewModel'
import { IMemoRouteParam,  } from "../types";
import { MemoDetailView } from "../components/MemoDetailView";
import { CustomTitleBar } from "../components/CustomTitleBar";
import EventManager ,{EventTypes} from '../utils/EventManager'
import { EditorHistoryManager } from "../components/Editor/HistoryManager";

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

@ComponentV2
struct CreateMemo {
  private pageInfos:NavPathStack = new NavPathStack()
  private editorOptions: RichEditorOptions = { controller: new RichEditorController() };
  private pageParams:IMemoRouteParam ={id:'-1'}
  @Provider() historyManager: EditorHistoryManager = new EditorHistoryManager(this.editorOptions.controller)
  @Local memoTitle:string = '标题'

  @Builder
  titleBarBuilder(){
    Row({space: 10}){
      Text(){
        SymbolSpan($r('sys.symbol.undo'))
      }
      .IconText(this.historyManager.canUndo)
      .onClick(()=>{
        this.historyManager.undo()
      })
      Text(){
        SymbolSpan($r('sys.symbol.redo'))
      }
      .IconText(this.historyManager.canRedo)
      .onClick(()=>{
        this.historyManager.redo()
      })
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
    let spans = this.editorOptions.controller.getSpans();

    let memoId = this.pageParams.id

    if(memoId == '-1'){
      await MemoViewModel.createMemo(title,spans)

    }else {
     //
      await MemoViewModel.updateMemo(memoId,title,spans)
      EventManager.emit(EventTypes.FETCH_MEMO_DETAIL)
    }
    EventManager.emit(EventTypes.FETCH_MEMO_LIST)
    this.pageInfos.pop()
  }
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)

  }
  build() {
    //
    NavDestination(){
      CustomTitleBar({
        onBackPress:()=>{
          this.pageInfos.pop(false)
        },
        extraContent:()=>{
          this.titleBarBuilder()
        }
      })
        .padding({left:15,right:15})
      MemoDetailView(
        {
          onGetTitle:(title)=>{
            this.memoTitle = title
          },
          editorOptions:this.editorOptions,
          pageParams:{id: this.pageParams.id}
        })
      .width('100%').layoutWeight(1)
    }
    .onReady((ctx)=>{

      this.pageInfos = ctx.pathStack
      this.pageParams = ctx.pathInfo.param as IMemoRouteParam

    })
    .height('100%')
    .hideTitleBar(true)

  }
}