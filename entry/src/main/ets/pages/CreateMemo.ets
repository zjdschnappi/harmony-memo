import { KeyboardAvoidMode } from "@ohos.arkui.UIContext";

@Builder
export function CreateMemoBuilder(){
  CreateMemo()
}

@Extend(Text)
function IconText(opacity:number = 1){
  .fontSize(26)
  .width(40)
  .height(40)
  .opacity(opacity)
  .backgroundColor('#dfdfdf')
  .borderRadius('50%')
  .textAlign(TextAlign.Center)
}

@Component
struct CreateMemo {
  pageInfos:NavPathStack = new NavPathStack()
  controller: RichEditorController = new RichEditorController();
  options: RichEditorOptions = { controller: this.controller };

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
          }.IconText(0.1)
          Text(){
            SymbolSpan($r('sys.symbol.redo'))
          }.IconText(0.1)
          Text(){
            SymbolSpan($r('sys.symbol.checkmark'))
          }.IconText(0.1)
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
        })
          .placeholderFont({
            size: 30
          })
          .defaultFocus(true)
          .caretColor(Color.Orange)
          .fontSize(30)
          .backgroundColor(Color.Transparent)
        RichEditor(this.options)
          .placeholder('写点什么吧...')
          .height('100%')
          .caretColor(Color.Orange)
          .onReady(() => {
            //
          })
      }
      .width('100%')
      .layoutWeight(1)
      Row(){
        List({space:20}){
          ListItem(){
            SymbolGlyph($r('sys.symbol.character_viewfinder')).fontSize(30)
          }
          ListItem(){
            SymbolGlyph($r('sys.symbol.face')).fontSize(30)
          }
          ListItem(){
            SymbolGlyph($r('sys.symbol.media_center')).fontSize(30)
          }
        }.listDirection(Axis.Horizontal).alignListItem(ListItemAlign.Center).padding({left:15,right:15})
      }.width('100%').height(40)
    }.onReady((ctx)=>{
      this.pageInfos = ctx.pathStack
    })
    .height('100%')
    .hideTitleBar(true)
  }
}