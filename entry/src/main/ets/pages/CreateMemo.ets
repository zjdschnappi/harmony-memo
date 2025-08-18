import { KeyboardAvoidMode } from "@ohos.arkui.UIContext";
import MemoViewModel from '../viewmodel/MemoViewModel'
import { IMemoRouteParam,  } from "../types";
import { IMemoContentItem } from "../model/Memo";
import { Editor } from "../components/Editor";

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
          this.pageInfos.pop()
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
      Column(){
        TextInput({
          placeholder:'标题',
          text: $$this.memoTitle
        })

          .placeholderFont({
            size: 30
          })

          .defaultFocus(true)
          .caretColor(Color.Orange)
          .fontSize(30)
          .backgroundColor(Color.Transparent)
        Editor({editorOptions:{controller:this.controller}}).layoutWeight(1)
      }
      .width('100%').layoutWeight(1)
    }.onReady((ctx)=>{
      this.pageInfos = ctx.pathStack
      this.pageParams = ctx.pathInfo.param as IMemoRouteParam
      MemoViewModel.getDetailById(this.pageParams.id).then((data)=>{

        this.memoTitle = data?.title||''
        data?.content?.forEach((item:IMemoContentItem)=>{
          if(typeof (item as RichEditorImageSpanResult).valueResourceStr!='undefined'){

          }else {
            let content = item as RichEditorTextSpanResult
            this.controller.addTextSpan(content.value,{
              style: content.textStyle
            })
          }
        })
      })
    })
    .height('100%')
    .hideTitleBar(true)
  }
}