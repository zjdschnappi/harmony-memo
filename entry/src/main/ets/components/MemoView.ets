import { MemoItemModel } from "../model/MemoItemModel"
import { IMemoRouteParam } from "../types"


@Component
struct  MemoItem {
  @ObjectLink item: MemoItemModel
  click: (item:MemoItemModel)=>void = ()=>{}
  build(){
    Column(){
      Text(this.item.title).fontSize(18).fontWeight(700)
      Row(){
        Text(this.item.content).fontSize(16)
        Text(this.item.time).fontSize(12)
      }.justifyContent(FlexAlign.SpaceBetween).width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start).border({
      width:{
        bottom: 1
      },
      color: '#dfdfdf'
    }).padding({left:10,right:10,top: 5, bottom: 5})
    .onClick(()=>{
      this.click(this.item)
    })

  }
}

@Component
export default struct MemoView {
  @Consume list: MemoItemModel[]
  pageInfos:NavPathStack = new NavPathStack()
  @Builder
  deleteItemBuilder(id:string){
    Button('删除').type(ButtonType.Normal).width(80).height('100%')
      .fontSize(14)
      .fontColor('#fff').backgroundColor(Color.Red)
      .onClick(()=>{
        this.getUIContext().getPromptAction().showDialog({
          title: '提示',
          message:'确认删除这条记录吗？',
          buttons:[
            {text:'取消',primary:false,color:'black'},
            {text:'确定',primary:true,color:'red'}
          ],

        }).then((value)=>{
          if(value.index==1){
            this.list = this.list.filter(item=>item.id!==id)
          }
        })

      })
  }
  handleDetail(item:MemoItemModel){
    let params:IMemoRouteParam = {id:item.id}
    this.pageInfos.pushPathByName('CreateMemo',params)
  }

  build(){
    //
    if(this.list.length){

      List(){
        ForEach(this.list,(item:MemoItemModel)=>{
          ListItem(){
            MemoItem({item:item,click:(detail)=>{
                this.handleDetail(detail)
            }})
          }.swipeAction({
            end: this.deleteItemBuilder(item.id)
          })

        })
      }.height('100%')
    }else {
      Text('暂无数据')
    }


  }
}