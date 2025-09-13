import { MemoSimpleListItemModel } from "../model/Memo"
import { CustomTitleBar } from "./CustomTitleBar"


@ComponentV2
export struct  MemoItemView {
  @Param @Require item: MemoSimpleListItemModel|null
  @Param isExpand:boolean = false
  build(){
    if(this.isExpand){

      //


    }else {

      Row(){
        Column({space: 10}){

          Text(this.item?.title).fontSize(18).fontWeight(700).width('100%')
          Row({space: 10}){
            Text(this.item?.simpleContent).fontSize(16)
            Text(this.item?.modifiedTime).fontSize(12)
          }
          .width('100%')
        }.layoutWeight(1)
        Image(this.item?.imgUrl?.[0]).objectFit(ImageFit.Contain).width(50).height(50)
      }
      .padding(15)
      .width('100%')
    }


  }
}