import { MemoSimpleListItemModel } from "../model/Memo"
import { CustomTitleBar } from "./CustomTitleBar"


@Component
export struct MemoItemView {
  @ObjectLink item: MemoSimpleListItemModel
  @Prop isExpand:boolean = false
  build(){
    Column(){
      if(this.isExpand){
        // TODO 跳转到详情页时给另一个样式
        CustomTitleBar({
          onBackPress:()=>{
            //
          }
        })


      }
      if(this.item.isPinned){
        Text('置顶')
          .backgroundColor(Color.Green)
          .padding({left:5,right:5})
          .position({left:-15,top:-15})
          .fontColor(Color.White).fontSize(12)
      }

      Text(this.item.title).fontSize(18).fontWeight(700)
      Row(){
        Text(this.item.simpleContent).fontSize(16)
        Text(this.item.modifiedTime).fontSize(12)
      }
      .justifyContent(FlexAlign.SpaceBetween).width('100%')
    }
    .padding(15)
    .width('100%')
    .alignItems(HorizontalAlign.Start)


  }
}