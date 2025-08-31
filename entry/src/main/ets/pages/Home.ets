import MemoView from '../components/MemoView';
import TodoView from '../components/TodoView';
import MemoViewModel from '../viewmodel/MemoViewModel'
import {  MemoSimpleListItemModel } from '../model/Memo';
import { IMemoRouteParam } from '../types';
import { CustomTransition } from '../customTransition/CustomNavigationUtils';

enum TabBarEnum {
  TODO = 'TODO',
  MEMO = 'MEMO'
}
interface ITabBarParams{
  text: string;
  type: TabBarEnum;
  index:number;
}

function initData(){
  const data:ITabBarParams[] = [
    {text:'备忘',type: TabBarEnum.MEMO,index:0},
    {text:'待办',type: TabBarEnum.TODO,index:1},

  ]
  return data
}

@Builder
function HomeBuilder(){

  Home()
}

@Component
struct Home {
  @Provide list: MemoSimpleListItemModel[] = []
  @Consume pagePathStackInfos:NavPathStack
  @State sidebarOpen:boolean = false
  @State currentTab:number = 0

  private pageId: number = -1;

  private registerCustomTransition(): void {
    // 注册自定义动画协议
    CustomTransition.getInstance().registerNavParam(this.pageId,
      (isPush: boolean, isExit: boolean, transitionProxy: NavigationTransitionProxy) => {}, 500);
  }
  @Builder
  TabBarBuilder(params:Partial<ITabBarParams>){
    Text(params.text).backgroundColor(this.currentTab==params.index?'#dedede':'transparent')
      .padding({top:10,left:20,right:20,bottom:10})
      .borderRadius(20)
  }
  aboutToAppear(){
    setTimeout(()=>{

      this.getMemoList()
    },500)
  }
  getMemoList(){
    MemoViewModel.getActiveMemos().then((data)=>{
      this.list = data.map(item=>{
        return new MemoSimpleListItemModel(
          item.memoId,
          item.title,
          item.simpleContent,
          item.createdTime,
          item.modifiedTime,
          item.imgUrl,
          item.isPinned,
          item.isArchived,
        )

      })
    })
  }
  build() {
    NavDestination(){
      Stack(){
        SideBarContainer(SideBarContainerType.Overlay){
          Column(){
            List(){

              ListItem(){
                Row(){
                  Row(){
                    SymbolGlyph($r('sys.symbol.list_square'))
                    Blank()
                    Text('全部备忘')
                  }
                  Text(String(this.list.length))
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width('100%')


              }.border({
                width:{
                  bottom: 1
                },
                color: '#dedede'
              })
              .padding({
                top:10,
                bottom:10,
                left:20,
                right:20
              })
            }.margin({top:100})
          }.height('100%').backgroundColor('#fff')
          Column(){
            Tabs(){
              ForEach(initData(),(item:ITabBarParams)=>{
                TabContent(){
                  if(item.type==TabBarEnum.MEMO){
                    MemoView()
                  }else {
                    TodoView()
                  }
                }.tabBar(this.TabBarBuilder({text:item.text,index:item.index}))


              })

            }.barWidth(150)
            .onChange((value)=>{
              this.currentTab = value
            })
            SymbolGlyph($r('sys.symbol.house_setting'))
              .position({top:15,right:20})
              .fontSize(25)
              .bindMenu([
                {
                  value: '设置',
                  action:()=>{
                    //
                  }
                }
              ])
            Row(){
              SymbolGlyph($r('sys.symbol.plus_circle'))
                .fontSize(30)
                .onClick(()=>{
                  const params:IMemoRouteParam= {id:'-1'}
                  this.pagePathStackInfos.pushPathByName('CreateMemo',params,()=>{
                    this.getMemoList()
                  })
                })
            }.width('100%')
            .justifyContent(FlexAlign.Center)
            .position({bottom:20,left:0,right:0})
          }.height('100%').width('100%').backgroundColor('#f3f3f3')

        }
        .showSideBar(this.sidebarOpen).showControlButton(false)

        SymbolGlyph(this.sidebarOpen? $r('sys.symbol.open_sidebar'):$r('sys.symbol.close_sidebar'))
          .position({top:15,left:20})
          .fontSize(25)
          .onClick(()=>{
            this.getUIContext().animateTo({
              duration:200
            },()=>{
              this.sidebarOpen=!this.sidebarOpen
            })
          })

      }
      .height('100%')
      .width('100%')
    }

    .onReady((context)=>{
      this.pageId = context.pathStack.getAllPathName().length - 1;
      this.registerCustomTransition();
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);

    })

  }
}