import { MemoSimpleListItemModel } from "../model/Memo"
import { IMemoRouteParam } from "../types"
import MemoViewModel from '../viewmodel/MemoViewModel'
import { CustomTitleBar } from "./CustomTitleBar"
import { MemoItem } from './MemoItem'



@ComponentV2
struct ListItemSwipeEnd {
  @Param @Require item:MemoSimpleListItemModel
  @Param onPinTop:()=>void = ()=>{}
  @Param onDelete:()=>void = ()=>{}
  // 是否开启多选模式
  @Local isMultiple:boolean = false
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



@ComponentV2
export default struct MemoView {
  private scroller:ListScroller = new ListScroller()
  @Consumer() list: MemoSimpleListItemModel[] = []
  @Consumer() pagePathStackInfos:NavPathStack = new NavPathStack()
  @Local isMultiple:boolean = false
  @Local checkedSet: Set<string> = new Set([])

  @Monitor('isMultiple')
  modeChange(){
    if(!this.isMultiple){
      this.checkedSet.clear()
    }
  }
  @Computed
  get checkedAll(){
    return this.checkedSet.size==this.list.length
  }
  @Builder
  contentCoverTitleBuilder(){
    Text(this.checkedSet.size?`已选择${this.checkedSet.size}项`:'未选择')
  }
  @Builder
  contentCoverBuilder(){
    Column(){
      CustomTitleBar({
        onBackPress:()=>{
          this.isMultiple = false
        },
        title:()=>{
          this.contentCoverTitleBuilder()
        }
      })
        .padding({
          left: 15,
          right: 15,
          top: 15
        })
      List({space: 15}){
        ForEach(this.list,(item:MemoSimpleListItemModel)=>{
          ListItem(){
            MemoItem({
              item:item,
              checkable:this.isMultiple,
              checked: this.checkedSet.has(item.memoId),
              onCheck:(id:string,checked:boolean)=>{
                if(checked){
                  this.checkedSet.add(id)
                }else {
                  this.checkedSet.delete(id)
                }
              }

            })
          }
          .transition(TransitionEffect.SLIDE)
        },(item:MemoSimpleListItemModel)=>{
          return item.memoId
        })

      }
      .alignListItem(ListItemAlign.Center)
      .layoutWeight(1)
      .backgroundColor(Color.Transparent)
      Row(){
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(30)
          .enabled(!!this.checkedSet.size)
          .onClick(()=>{
            this.handleBatchDelete()
          })
        SymbolGlyph(
          this.checkedAll? $r('sys.symbol.checkmark_square_on_square')
          : $r('sys.symbol.checkmark_square_on_square_fill')
        ).fontSize(30)
          .onClick(()=>{
            if(this.checkedAll){
              this.checkedSet.clear()
            }else {
              let ids = this.list.map(item=>item.memoId)
              this.checkedSet = new Set(ids)
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding({bottom: 15})
    .backgroundColor('#f3f3f3')
    .height('100%')
  }
  @Builder
  contextBuilder(id:string) {
    Menu() {
      MenuItem({ content: "删除" }).onClick(()=>{
        this.handleDelete(id)
      })
      MenuItem({ content: "多选" }).onClick(()=>{
        this.isMultiple = true
      })
    }
  }

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
  handleBatchDelete(){
    let ids = Array.from(this.checkedSet);

    this.getUIContext().getPromptAction().showDialog({
      title: '提示',
      message: `确认删除${ids.length==1?'这条':`这${ids.length}条`}记录吗？`,
      buttons:[
        {text:'取消',primary:false,color:'black'},
        {text:'确定',primary:true,color:'red'}
      ],

    }).then((value)=>{
      if(value.index==1){
        MemoViewModel.deleteMemo(ids).then(()=>{
          this.list = this.list.filter(item=>!ids.find(id=>id==item.memoId))
          this.isMultiple = false
        })
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
        MemoViewModel.deleteMemo([id])
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
    this.pagePathStackInfos.pushPathByName('MemoDetail',params)
  }

  build(){
    //
    Column(){

      if(this.list.length){

        List({scroller:this.scroller,space: 15}){
          ForEach(this.list,(item:MemoSimpleListItemModel)=>{
            if(!this.isMultiple){

              ListItem(){
                MemoItem({
                  item:item,
                  onDetail:(params:IMemoRouteParam)=>{
                   this.handleDetail(params)
                  }
                })

              }
              .bindContextMenu(this.contextBuilder(item.memoId),ResponseType.LongPress,{
                preview: MenuPreviewMode.IMAGE,
                previewAnimationOptions: {scale: [0.8, 1.0]},
              })
              .swipeAction({
                end: this.endBuilder(item)
              })
              .transition(TransitionEffect.SLIDE)

            }


            },(item:MemoSimpleListItemModel)=>`${item.memoId}`
          )
        }
        .margin({top: 15})
        .height('100%')
        .alignListItem(ListItemAlign.Center)
        .backgroundColor(Color.Transparent)


      }else {
        Text('暂无数据')
      }
    }
    .bindContentCover($$this.isMultiple,this.contentCoverBuilder(),ModalTransition.NONE)


  }
}