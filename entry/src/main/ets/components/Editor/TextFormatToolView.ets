import { IColorItemParams, ITextColorItem, ITextDecoratorItem, ITypingStyleParam } from "../../types";
import EventManager ,{ EventTypes } from "../../utils/EventManager";

const defaultColor = '#E5000000'

@ComponentV2
export struct TextFormatToolView {
  @Local showTextToolBar:boolean = false
  @Local fontSize:number = 16
  @Local isBold:boolean = false
  @Local isItalic:boolean = false
  @Local isUnderline:boolean = false
  @Local textColor:Color|string = defaultColor
  @Local paragraphStyle:TextAlign = TextAlign.Start
  @Local selectionRange: RichEditorRange = {start:0,end:0}
  @Param controller: RichEditorController = new RichEditorController()



  aboutToAppear(): void {
    EventManager.on(EventTypes.EDITOR_SELECTION_CHANGE,(e)=>{
      this.selectionRange = e.data?.data as RichEditorRange
      this.setSelectionRangeState(e.data?.data as RichEditorRange)
    })
  }
  @Builder
  colorItem(params:IColorItemParams){

    SymbolGlyph($r('sys.symbol.smallcircle_filled_circle'))
      .backgroundColor(params.color)
      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
      .fontColor(String(this.textColor).toLowerCase()==String(params.color).toLowerCase()?[Color.Transparent,Color.White]:[Color.Transparent,Color.Transparent])
      .fontSize(26).borderRadius('50%').onClick(()=>{
      params.onClick(params.color)
    })
  }
  @Builder
  textToolBuilder(){
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
          this.colorItem({color:item.color,onClick:(item:Color|string)=>{
            this.textColor = item
            if(this.checkIsSelectRange()){
              this.controller.updateSpanStyle({
                start: this.selectionRange.start,
                end: this.selectionRange.end,
                textStyle:this.getTypingStyles({textColor:item})
              })
            }else {
              this.controller.setTypingStyle(this.getTypingStyles({textColor:item}))

            }

          }

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
            if(this.checkIsSelectRange()){
              this.controller.updateSpanStyle({
                start: this.selectionRange.start,
                end: this.selectionRange.end,
                textStyle:this.getTypingStyles({fontSize:v})
              })
            } else {
              this.controller.setTypingStyle(this.getTypingStyles({fontSize:v}))
            }

          })
          .layoutWeight(1)
          .trackColor('#dfdfdf')
          .selectedColor(Color.Orange)
        Text('Aa').fontSize(30).fontWeight(700)
      }.width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .margin({top: 25,bottom: 25})
    .padding({left: 10,right: 10})


  }
  textDecoratorItems(){
    let list:ITextDecoratorItem[] =  [
      {
        icon: $r('sys.symbol.pencil_line_1'),
        onClick:()=>{
          this.isUnderline=!this.isUnderline
          if(this.checkIsSelectRange()){
            this.controller.updateSpanStyle({
              start: this.selectionRange.start,
              end: this.selectionRange.end,
              textStyle: this.getTypingStyles({isUnderline:this.isUnderline})
            })
          }else {
            this.controller.setTypingStyle(this.getTypingStyles({isUnderline:this.isUnderline}))
          }

        },
        active: this.isUnderline
      },
      {
        icon: $r('sys.symbol.character_viewfinder'),
        onClick:()=>{
          this.isBold = !this.isBold
          if(this.checkIsSelectRange()){
            this.controller.updateSpanStyle({
              start: this.selectionRange.start,
              end: this.selectionRange.end,
              textStyle:this.getTypingStyles({isBold:this.isBold})
            })
          }else {
            this.controller.setTypingStyle(this.getTypingStyles({isBold:this.isBold}))
          }

        },
        active: this.isBold
      },
      {
        icon: $r('sys.symbol.selector'),
        onClick:()=>{
          this.isItalic = !this.isItalic
          if(this.checkIsSelectRange()){
            this.controller.updateSpanStyle({
              start: this.selectionRange.start,
              end: this.selectionRange.end,
              textStyle: this.getTypingStyles({isItalic:this.isItalic})
            })
          }else {
            this.controller.setTypingStyle(this.getTypingStyles({isItalic:this.isItalic}))
          }

        },
        active: this.isItalic
      },
      {
        icon: $r('sys.symbol.text_alignleft'),
        onClick:()=>{
          this.paragraphStyle = TextAlign.Start
          this.controller.updateParagraphStyle({
            style: {
              textAlign: TextAlign.Start
            }
          })
        },
        active: this.paragraphStyle == TextAlign.Start
      },
      {
        icon: $r('sys.symbol.text_aligncenter'),
        onClick:()=>{
          this.paragraphStyle = TextAlign.Center
          this.controller.updateParagraphStyle({
            style: {
              textAlign: TextAlign.Center
            }
          })
        },
        active: this.paragraphStyle == TextAlign.Center
      },

      {
        icon: $r('sys.symbol.text_alignright'),
        onClick:()=>{
          this.paragraphStyle = TextAlign.End
          this.controller.updateParagraphStyle({
            style: {
              textAlign: TextAlign.End
            }
          })
        },
        active: this.paragraphStyle == TextAlign.End
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
        color:defaultColor
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
  checkIsSelectRange(){
    return (this.selectionRange.start||0)<(this.selectionRange.end||0)
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
  // 获取选中区域的格式从而高亮工具栏
  setSelectionRangeState(v:RichEditorRange){
    let spans = this.controller.getSpans({start:v.start,end:v.end});
    let fontSizeSet:Set<number> = new Set()
    let fontColorSet:Set<ResourceColor> = new Set()
    let fontStyleSet:Set<FontStyle> = new Set()
    let fontWeightSet:Set<number> = new Set()
    let textDecorateStyleSet:Set<TextDecorationType> = new Set()
    let paragraphTypeSet:Set<TextAlign> = new Set()

    spans.forEach((item)=>{
      let span = item as RichEditorImageSpanResult
      if(typeof span.imageStyle!=='undefined'){
        //
      }else {
        let span = item as RichEditorTextSpanResult;
        fontSizeSet.add(span.textStyle.fontSize)
        fontColorSet.add(span.textStyle.fontColor)
        fontStyleSet.add(span.textStyle.fontStyle)
        fontWeightSet.add(span.textStyle.fontWeight)
        textDecorateStyleSet.add(span.textStyle.decoration.type)
        paragraphTypeSet.add(span.paragraphStyle?.textAlign||TextAlign.Start)

      }
      if(fontSizeSet.size==1){
        this.fontSize = fontSizeSet.values().next().value
      }
      if(fontColorSet.size==1){
        this.textColor = fontColorSet.values().next().value

      }
      if(fontWeightSet.size==1){
        this.isBold = fontWeightSet.values().next().value == 9
      }

      if(fontStyleSet.size==1){
        this.isItalic = fontStyleSet.values().next().value == FontStyle.Italic
      }
      if(textDecorateStyleSet.size==1){
        this.isUnderline =( textDecorateStyleSet.values().next().value as TextDecorationType) ==  TextDecorationType.Underline
      }
      if(paragraphTypeSet.size==1){
        this.paragraphStyle =( paragraphTypeSet.values().next().value as TextAlign)
      }

    })
  }
  build(){

    SymbolGlyph($r('sys.symbol.character_viewfinder')).fontSize(30)
      .onClick(()=>{
        this.showTextToolBar = true
      })
      .bindSheet($$this.showTextToolBar, this.textToolBuilder(), {
        height:SheetSize.FIT_CONTENT,
        backgroundColor: Color.White,
      })
  }
}