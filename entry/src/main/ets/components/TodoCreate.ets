
@Extend(Row)
function rowAttr(){
  .width('90%')
  .padding({top:10,bottom:10,left:15,right:15})
  .backgroundColor(Color.White)
  .borderRadius(15)
}

@ComponentV2
export struct TodoCreate {
  @Local title:string='';
  @Local memo:string='';
  build() {

    Column({space: 15}){

      Row(){
        Text('待办事项')
        TextInput({text: this.title,placeholder:'请输入待办事项'}).layoutWeight(1).backgroundColor(Color.Transparent)
      }.rowAttr()

      Row(){
        Text('时间提醒')
        TextInput({placeholder:'请选择提醒时间',}).focusable(false).layoutWeight(1).backgroundColor(Color.Transparent)
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(20)
      }.rowAttr()

      Row(){
        Text('位置提醒')
        TextInput({placeholder:'请选择提醒位置',}).focusable(false).layoutWeight(1).backgroundColor(Color.Transparent)
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(20)
      }.rowAttr()

      Row(){
        Text('备注')
        TextInput({text: this.memo,placeholder:'请输入备注',}).layoutWeight(1).backgroundColor(Color.Transparent)
      }.rowAttr()


    }
    .margin({top: 15})
    .width('100%')
    .height('100%')
  }
}