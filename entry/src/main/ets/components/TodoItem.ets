import { TodoItemSimpleModel } from "../model/Todo"

@ComponentV2
export struct TodoItem {
  @Param @Require info: TodoItemSimpleModel
  @Param onCheck:(v:boolean)=>void = ()=>{}
  build() {
    Row(){
      Checkbox()
        .select($$this.info.isCompleted)
        .onChange((v)=>{
          this.onCheck(v)
        })
      Column(){
        Text(this.info.title)
          .fontColor(this.info.isCompleted ? Color.Gray : Color.Black)
          .decoration({ type: this.info.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
        Text(this.info.dueTime).fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 15 })

    }
    .padding(15)
    .backgroundColor(Color.White)
    .width('90%')
    .borderRadius(15)

  }
}

@Builder
export function endBuilder(item: TodoItemSimpleModel) {
  SymbolGlyph($r('sys.symbol.trash'))
    .fontSize(30)
    .margin({left: 15})
}