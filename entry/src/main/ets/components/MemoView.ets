import { MemoSimpleListItemModel } from "../model/Memo"
import { IMemoRouteParam } from "../types"
import MemoViewModel from '../viewmodel/MemoViewModel'

@Component
struct  MemoItem {
  @ObjectLink item: MemoSimpleListItemModel
  click: (item:MemoSimpleListItemModel)=>void = ()=>{}
  build(){
    Column(){
      Text(this.item.title).fontSize(18).fontWeight(700)
      Row(){
        Text(this.item.simpleContent).fontSize(16)
        Text(this.item.modifiedTime).fontSize(12)
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
  @Consume list: MemoSimpleListItemModel[]
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
           //
            MemoViewModel.deleteMemo(id).then(()=>{
               this.getMemoList()
            })
          }
        })

      })
  }
  getMemoList(){
    MemoViewModel.getActiveMemos().then((data)=>{
      this.list = data
    })
  }
  handleDetail(item:MemoSimpleListItemModel){
    let params:IMemoRouteParam = {id:item.memoId}
    this.pageInfos.pushPathByName('CreateMemo',params,()=>{
      this.getMemoList()
    })
  }

  build(){
    //
    if(this.list.length){

      List(){
        ForEach(this.list,(item:MemoSimpleListItemModel)=>{
          ListItem(){
            MemoItem({item:item,click:(detail)=>{
                this.handleDetail(detail)
            }})
          }.swipeAction({
            end: this.deleteItemBuilder(item.memoId)
          })

        })
      }.height('100%')
    }else {
      Text('暂无数据')
    }


  }
}