
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

@Component
export struct CustomTitleBar {
  @BuilderParam extraContent?: () => void  // 定义插槽
  onBackPress?:()=> void = ()=> {}
  build() {

    Row(){
      Text(){
        SymbolSpan($r('sys.symbol.chevron_left'))

      }
      .IconText()
      .onClick(()=>{
        this.onBackPress?.()
      })
     this.extraContent?.()
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(80)
  }
}