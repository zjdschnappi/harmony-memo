import { MemoSimpleListItemModel } from "../model/Memo"
import { IMemoRouteParam } from "../types"
import MemoViewModel from '../viewmodel/MemoViewModel'
import { MemoItem } from './MemoItem'



@Component
struct ListItemSwipeEnd {
  @ObjectLink item:MemoSimpleListItemModel
  onPinTop:()=>void = ()=>{}
  onDelete:()=>void = ()=>{}
  build(){
    Row({space: 10}){
      SymbolGlyph(
        this.item.isPinned?$r('sys.symbol.arrowshape_down_to_line_fill'):$r('sys.symbol.arrowshape_up_to_line_fill')
      )
        .fontSize(30)
        .fontColor([Color.Brown])
        .onClick(()=>{
          this.onPinTop()
        })
      SymbolGlyph($r('sys.symbol.folder')).fontSize(30).fontColor([Color.Green])
      SymbolGlyph($r('sys.symbol.trash')).fontSize(30).fontColor([Color.Red])
        .onClick(()=>{
          this.onDelete()
        })
    }.margin({left: 5})

  }
}

@Component
export default struct MemoView {
  @Consume list: MemoSimpleListItemModel[]
  @Consume pagePathStackInfos:NavPathStack
  scroller:ListScroller = new ListScroller()

  @Builder
  endBuilder(item:MemoSimpleListItemModel){
    ListItemSwipeEnd({
      item:item,
      onPinTop:()=>{
        this.handlePinTop(item.memoId)
      },
      onDelete:()=>{
        this.handleDelete(item.memoId)
      }
    })
  }
  handlePinTop(id:string){
    MemoViewModel.togglePin(id)
    this.scroller.closeAllSwipeActions()
    let index = this.list.findIndex(item=>item.memoId==id)
    let notPinnedIndex = this.list.findIndex(item=>!item.isPinned)
    let lastPinnedIndex = -1
    for(let i=this.list.length-1;i>=0;i--){
      if(this.list[i].isPinned){
        lastPinnedIndex = i
        break;
      }
    }
    let current = this.list[index];
    let isPinned = current.isPinned
    this.list[index].isPinned = !current.isPinned
    this.getUIContext().animateTo({duration:300},()=>{
      if(isPinned){
        if(lastPinnedIndex>index){
          this.list.splice(index,1)
          this.list.splice(lastPinnedIndex,0,current)
        }
      }else {
        if(notPinnedIndex<index){
          this.list.splice(index,1)
          this.list.splice(notPinnedIndex,0,current)
        }
      }
    })

  }
  handleDelete(id:string){
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
        MemoViewModel.deleteMemo(id)
        let index = this.list.findIndex(item=>item.memoId==id)
        if(index>-1){
          this.getUIContext().animateTo({duration:300},()=>{

            this.list.splice(index,1)
          })
        }
      }else {
        this.scroller.closeAllSwipeActions()
      }
    })
  }
  handleDetail=(params:IMemoRouteParam)=>{
    let p:Promise<void> =  new Promise((resolve,reject)=>{

      this.pagePathStackInfos.pushPathByName('MemoDetail',params,()=>{
        this.getMemoList()
      })
      resolve()
    })
    return p
  }
  getMemoList(){
    MemoViewModel.getActiveMemos().then((data)=>{
      this.list = data
    })
  }

  build(){
    //
    if(this.list.length){

      List({scroller:this.scroller}){
        ForEach(this.list,(item:MemoSimpleListItemModel)=>{
          ListItem(){
            MemoItem({item:item,onDetail:this.handleDetail})
          }

          .margin({top:15})
          .backgroundColor(Color.White)
          .swipeAction({
            end: this.endBuilder(item)
          })
          .borderRadius(5)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
          .border({
            width:{
              bottom: 1
            },
            color: '#dfdfdf'
          })
          .transition(TransitionEffect.SLIDE)


          },(item:MemoSimpleListItemModel,)=>`${item.memoId}`
        )
      }
      .height('100%')
      .margin({left:15,right:15})
      .backgroundColor(Color.Transparent)

    }else {
      Text('暂无数据')
    }


  }
}