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
      CustomTitleBar({
        onBackPress:()=>{
          this.pageInfos.pop()
        },
        extraContent:()=>{
          this.titleBarBuilder()
        }
      })
        .padding({left:15,right:15})
      MemoDetailView()
      .width('100%').layoutWeight(1)
    }
    .systemTransition(NavigationSystemTransitionType.NONE)
    .onReady((ctx)=>{

      this.pageInfos = ctx.pathStack
      this.pageParams = ctx.pathInfo.param as IMemoRouteParam

      this.handleGetDetail()
    })
    .height('100%')
    .hideTitleBar(true)

  }
}