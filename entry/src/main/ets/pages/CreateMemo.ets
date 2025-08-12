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

interface ColorItemParams {
  color:Color
  onClick:(item:Color)=>void
  active?:boolean
}
@Builder
function colorItem(params:ColorItemParams){

  SymbolGlyph($r('sys.symbol.smallcircle_filled_circle'))
    .backgroundColor(params.color)
    .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
    .fontColor(params.active?[Color.Transparent,Color.White]:[Color.Transparent,Color.Transparent])
    .fontSize(26).borderRadius('50%').onClick(()=>{
    params.onClick(params.color)
  })
}


interface ITextDecoratorItem{
  icon: Resource;
  onClick:()=>void;
  active?:boolean;
}
interface ITextColorItem{
  color: Color;
}
interface ITypingStyleParam{
  textColor?: Color;
  fontSize?: number;
  isBold?: boolean;
  isItalic?: boolean;
  isUnderline?: boolean;
}

@Preview
@Component
struct CreateMemo {
  pageInfos:NavPathStack = new NavPathStack()
  controller: RichEditorController = new RichEditorController();
  options: RichEditorOptions = { controller: this.controller };
  @State fontSize:number = 16
  @State showToolBar:boolean = false
  @State isBold:boolean = false
  @State isItalic:boolean = false
  @State isUnderline:boolean = false
  @State textColor:Color = Color.Black

  @Builder
  toolbarBuilder(){
    Column(){
      Text('样式').width('100%').textAlign(TextAlign.Start).fontSize(24).fontWeight(700)
      Row({space:25}){
        ForEach(this.textDecoratorItems(),(item:ITextDecoratorItem)=>{
          Text(){
            SymbolSpan(item.icon).fontColor(item.active?[Color.White]:[Color.Black]).fontSize(30)
          }
          .backgroundColor(item.active?Color.Orange:Color.Transparent)
          .borderRadius('50%').width(40).height(40).textAlign(TextAlign.Center).onClick(item.onClick)

        })

      }.width('100%').height(60).margin({top: 15}).justifyContent(FlexAlign.SpaceBetween)
      Divider().width('100%')
      Row({space:25}){
        ForEach(this.textDirectionItems(),(item:ITextDecoratorItem)=>{
          Text(){
            SymbolSpan(item.icon).fontColor(item.active?[Color.White]:[Color.Black]).fontSize(30)
          }
          .backgroundColor(item.active?Color.Orange:Color.Transparent)
          .borderRadius('50%')
          .width(40).height(40)
          .textAlign(TextAlign.Center)
        })

      }.width('100%').height(60).justifyContent(FlexAlign.SpaceBetween)
      Divider().width('100%')
      Row({space: 25}){
        ForEach(this.colorItems(),(item:ITextColorItem)=>{
          colorItem({color:item.color,onClick:(item:Color)=>{
            this.textColor = item
            this.controller.setTypingStyle(this.getTypingStyles({textColor:item}))
          },
            active: this.textColor==item.color
          })
        })
      }.width('100%').height(60).justifyContent(FlexAlign.SpaceBetween)
      Row(){
        Text('Aa').fontSize(14).fontWeight(700)
        Slider({
          value:this.fontSize,
          min:14,
          max:30,
          step:1,
          style:SliderStyle.InSet,
        })
          .onChange((v)=>{
            this.fontSize = v
            this.controller.setTypingStyle(this.getTypingStyles({fontSize:v}))
          })
          .layoutWeight(1).trackColor('#dfdfdf').selectedColor(Color.Orange)
        Text('Aa').fontSize(30).fontWeight(700)
      }.width('100%').alignItems(VerticalAlign.Center)
    }.margin({top: 25,bottom: 25}).padding({left: 10,right: 10})


  }
  getTypingStyles(params:ITypingStyleParam){
    let styles:RichEditorTextStyle = {
      // 字体颜色
      fontColor:params.textColor||this.textColor,
      // 字体大小
      fontSize: params.fontSize||this.fontSize,
      // 字体粗细
      fontWeight: params.isBold??this.isBold?FontWeight.Bold:FontWeight.Normal,
      // 字体斜体
      fontStyle: params.isItalic??this.isItalic?FontStyle.Italic:FontStyle.Normal,
      // 字体下划线
      decoration:params.isUnderline??this.isUnderline?{
        type: TextDecorationType.Underline,
        style:TextDecorationStyle.SOLID
      }:undefined
    }
    return styles
  }
  textDecoratorItems(){
    let list:ITextDecoratorItem[] =  [
      {
        icon: $r('sys.symbol.pencil_line_1'),
        onClick:()=>{
          this.isUnderline=!this.isUnderline
          this.controller.setTypingStyle(this.getTypingStyles({isUnderline:this.isUnderline}))
        },
        active: this.isUnderline
      },
      {
        icon: $r('sys.symbol.character_viewfinder'),
        onClick:()=>{
          this.isBold = !this.isBold
          this.controller.setTypingStyle(this.getTypingStyles({isBold:this.isBold}))
        },
        active: this.isBold
      },
      {
        icon: $r('sys.symbol.selector'),
        onClick:()=>{
          this.isItalic = !this.isItalic
          this.controller.setTypingStyle(this.getTypingStyles({isItalic:this.isItalic}))
        },
        active: this.isItalic
      },
      {
        icon: $r('sys.symbol.text_aligncenter'),
        onClick:()=>{}
      },
      {
        icon: $r('sys.symbol.text_alignleft'),
        onClick:()=>{}
      },
      {
        icon: $r('sys.symbol.text_alignright'),
        onClick:()=>{}
      },
    ]
    return list
  }
  textDirectionItems(){
    let list:ITextDecoratorItem[] =  [
      {
        icon: $r('sys.symbol.indent_right'),
        onClick:()=>{}
      },
      {
        icon: $r('sys.symbol.indentation_left'),
        onClick:()=>{}
      },
      {
        icon: $r('sys.symbol.list_letter'),
        onClick:()=>{}
      },
      {
        icon: $r('sys.symbol.list_number'),
        onClick:()=>{}
      },
      {
        icon: $r('sys.symbol.list_square'),
        onClick:()=>{}
      },
      {
        icon: $r('sys.symbol.list_bullet'),
        onClick:()=>{}
      },
    ]
    return list
  }
  colorItems(){
    let list:ITextColorItem[] = [
      {
        color:Color.Black,
      },
      {
        color:Color.Blue,

      },
      {
        color:Color.Brown,

      },
      {
        color:Color.Orange,

      },
      {
        color:Color.Red,

      },
      {
        color:Color.Yellow,
      },

    ]
    return list
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