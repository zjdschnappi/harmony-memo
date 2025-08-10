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
  @State showToolBar:boolean = false

  @Builder
  toolbarBuilder(){
    Column(){
      Text('样式').width('100%').textAlign(TextAlign.Start).fontSize(25).fontWeight(700)
      Row({space:25}){
        SymbolGlyph($r('sys.symbol.text_aligncenter')).fontSize(30)
        SymbolGlyph($r('sys.symbol.text_alignleft')).fontSize(30)
        SymbolGlyph($r('sys.symbol.text_alignright')).fontSize(30)

      }.width('100%').height(60).margin({top: 25})
      Divider().width('100%')
      Row({space:25}){
        SymbolGlyph($r('sys.symbol.list_letter')).fontSize(30)
        SymbolGlyph($r('sys.symbol.list_number')).fontSize(30)
        SymbolGlyph($r('sys.symbol.list_square')).fontSize(30)
        SymbolGlyph($r('sys.symbol.indent_right')).fontSize(30)
        SymbolGlyph($r('sys.symbol.indentation_left')).fontSize(30)

      }.width('100%').height(60)
      Divider().width('100%')
    }.margin({top: 25}).padding({left: 10,right: 10,bottom: 10})


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
              .onClick(()=>{
                this.showToolBar = true
              })
              .bindSheet($$this.showToolBar, this.toolbarBuilder(), {
                height:SheetSize.FIT_CONTENT,
                backgroundColor: Color.White,
                onWillAppear: () => {
                  console.log("BindSheet onWillAppear.");
                },
                onAppear: () => {
                  console.log("BindSheet onAppear.");
                },
                onWillDisappear: () => {
                  console.log("BindSheet onWillDisappear.");
                },
                onDisappear: () => {
                  console.log("BindSheet onDisappear.");
                }
            })
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