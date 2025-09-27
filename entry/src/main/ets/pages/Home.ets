import MemoView from '../components/MemoView';
import TodoView from '../components/TodoView';
import MemoViewModel from '../viewmodel/MemoViewModel'
import {  MemoSimpleListItemModel } from '../model/Memo';
import { ITransitionRouteParam } from '../types';
import { CustomTransition } from '../customTransition/CustomNavigationUtils';
import EventManager, { EventTypes } from '../utils/EventManager'
import { LoadingView } from '../components/LoadingView';

/**
 * 同步两个数组数据
 * @param {Array} oldArray - 原始数组（将被修改）
 * @param {Array} newArray - 新数据数组
 */
interface IParam {
  item: MemoSimpleListItemModel;
  index:number
}
function syncArrays(oldArray:MemoSimpleListItemModel[], newArray:MemoSimpleListItemModel[]) {
  // 创建ID映射以便快速查找
  const oldMap = new Map<string,IParam>();
  oldArray.forEach((item, index) => oldMap.set(item.memoId, { item, index }));

  const newMap = new Map<string,MemoSimpleListItemModel>();
  newArray.forEach(item => newMap.set(item.memoId, item));

  // 找出需要移除的数据（在旧数组但不在新数组中）
  const toRemove:number[] = [];
  for (let i = oldArray.length - 1; i >= 0; i--) {
    if (!newMap.has(oldArray[i].memoId)) {
      toRemove.push(i);
    }
  }

  // 从后往前删除，避免索引变化问题
  toRemove.forEach(index => {
    oldArray.splice(index, 1);
  });

  // 更新和新增数据
  newArray.forEach(newItem => {
    const oldEntry = oldMap.get(newItem.memoId);

    if (oldEntry) {
      // 更新现有项
      const oldItem = oldEntry.item;
      oldItem.title = newItem.title
      oldItem.simpleContent = newItem.simpleContent
      oldItem.modifiedTime = newItem.modifiedTime
      oldItem.imgUrl = newItem.imgUrl
      oldItem.isPinned = newItem.isPinned
      oldItem.isArchived = newItem.isArchived

    } else {
      // 新增项
      oldArray.push(new MemoSimpleListItemModel(
        newItem.id,
        newItem.memoId,
        newItem.title,
        newItem.simpleContent,
        newItem.createdTime,
        newItem.modifiedTime,
        newItem.imgUrl,
        newItem.isPinned,
        newItem.isArchived,
      ));
    }
  });
}
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

@ComponentV2
struct Home {
  @Provider() list: MemoSimpleListItemModel[] = []
  @Consumer() pagePathStackInfos:NavPathStack = new NavPathStack()
  @Local sidebarOpen:boolean = false
  @Local currentTab:number = 0
  private loadingView = new LoadingView()

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

    EventManager.on(EventTypes.FETCH_MEMO_LIST,()=>{
      this.getMemoList()

    })
  }
  aboutToDisappear(): void {
    EventManager.off(EventTypes.FETCH_MEMO_LIST)
  }
  getMemoList=()=>{

    this.loadingView.showLoading()
    setTimeout(()=>{
      // 模拟接口
      MemoViewModel.getActiveMemos().then((data)=> {
        syncArrays(this.list,data)
        this.loadingView.hide()
      })
    },500)
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