import { formatDate } from "../utils/DateUtil";
import { dateTimePickerDialog } from "./DateTimePicker/DateTimePickerDialog";
import { DateTimePickerParam, TimeFormat } from "./DateTimePicker/DateTimePickerInterface";
import { calendarManager } from "@kit.CalendarKit";
import { BusinessError } from '@kit.BasicServicesKit';
import { createNode, ItemNode } from "./ItemNode";
import { ITodoDetailModel, TodoItemSimpleModel } from "../model/Todo";
import { ICreateItemNodeBuilderProp, TodoItemBuilder } from "./TodoItem";
import TodoViewModel from '../viewmodel/TodoViewModel'
import EventManager, { EventTypes } from '../utils/EventManager'
import { CustomTitleBar } from "./CustomTitleBar";
import { StorageNameEnum, StorageUtil } from "../utils/StorageUtil";
import { common } from "@kit.AbilityKit";


@Extend(Row)
function rowAttr(){
  .width('90%')
  .padding({top:10,bottom:10,left:15,right:15})
  .backgroundColor(Color.White)
  .borderRadius(15)
}



@ComponentV2
export struct TodoCreateFormView {
  @Consumer() calendar?:calendarManager.Calendar
  @Local private title:string|null='';
  @Local private memo:string|null='';
  @Local private time:Date|null = null;
  @Local private myNodeController: ItemNode<TodoItemSimpleModel> | undefined = new ItemNode(false);
  @Local private checked:boolean = false
  @Param onSubmitSuccess:()=>void = ()=>{}
  @Param onCancel:()=>void = ()=>{}
  @Param detailData: ITodoDetailModel|null = null
  @Param sheetTitle:string = '新建待办'
  private storageFromDisk = new StorageUtil(this.getUIContext().getHostContext() as common.UIAbilityContext,StorageNameEnum.CALENDAR_EVENT)
  private textController:TextInputController = new TextInputController()
  private wrapBuilder = wrapBuilder(TodoItemBuilder)
  private openDateTimePicker = ( onConfirm: (selectedDate: Date) => void) => {
    dateTimePickerDialog(this.getUIContext(), {
      data: {
        startYear: 1980,
        endYear: 2100,
        selectedDate: new Date(),
        resultCb: (selectedDate: Date) => {
          onConfirm(selectedDate);
        },
      },
      option: {
        timeFormat: TimeFormat.MINUTES,
        isLoop: false,
      },
      style: {
        backgroundColor: Color.White,
        borderRadius: 15,
        borderColor: Color.Orange,
        borderWidth: 3,
        margin: 4
      }
    } as DateTimePickerParam, '提醒时间', {
      alignment: DialogAlignment.Center,
      offset: ({ dx: 0, dy: -4 }),
    });
  }
  handlePublishCalendar(id:string){

    if(this.storageFromDisk.has(id)){
      if(!this.time||this.checked){
        this.calendar?.deleteEvent(this.storageFromDisk.get(id)as number)
        return
      }
    }

    if(!this.time) return
    const event: calendarManager.Event = {
      // 日程标题
      title: this.title!,
      // 日程类型，不推荐三方开发者使用calendarManager.EventType.IMPORTANT，重要日程类型不支持一键服务跳转功能及无法自定义提醒时间
      type: calendarManager.EventType.NORMAL,
      // 日程开始时间
      startTime: this.time!.getTime(),
      // 日程结束时间
      endTime: this.time!.getTime() + 60 * 60 * 1000,
      // 距开始时间提前10分钟提醒
      reminderTime: [5],

    };

    if(!this.storageFromDisk.has(id)){
      this.calendar?.addEvent(event).then((data: number) => {
        console.info(`Succeeded in adding event, id -> ${data}`);
        this.storageFromDisk.set(id,data)
      }).catch((err: BusinessError) => {
        console.error(`Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
      });
    }
    else {
      event.id = this.storageFromDisk.get(id) as number
      this.calendar?.updateEvent(event)
    }



    //todo
    // 待办完成的时候，待办删除的时候，都要移除日程
  }
  private handleSubmit= async ()=>{
    if(!this.title) return
    let id:string|null = null
    try{
      if(this.detailData?.todoId){

        id = await TodoViewModel.update({
          todoId: this.detailData.todoId,
          title:this.title,
          isCompleted: this.checked,
          dueTime: this.time?formatDate(this.time):undefined,
          memo: this.memo
        })
      }
      else {
        id = await TodoViewModel.create({
          title:this.title,
          dueTime: this.time?formatDate(this.time):undefined,
          memo: this.memo
        })
      }

      EventManager.emit(EventTypes.FETCH_TODO_LIST)
      this.handlePublishCalendar(id)
      this.onSubmitSuccess()
    }
    catch(e) {
      console.log('222')
    }

  }
  private handleInput=(v:string)=>{
    //
    this.title = v
  }
  private handleCheck=(checked:boolean)=>{
    //
    this.checked = checked
  }
  @Monitor('detailData')
  handleDetailChange(){
    let item :TodoItemSimpleModel|null = null
    let data = this.detailData;
    if(data){
      item = new TodoItemSimpleModel(data?.id,data?.todoId,data?.title,data?.createdTime
        ,data?.modifiedTime,data.isCompleted,data?.priority,data?.dueTime,data?.location,data?.memo)
      this.memo = data.memo??null;
      this.title = data.title;
      this.time = data.dueTime?new Date(data.dueTime):null
    }
    this.myNodeController?.update(true,item)
  }

  aboutToAppear(): void {
      // 新建自定义节点
    let builderData:ICreateItemNodeBuilderProp = {
      item:null,
      isExpand:true,
      onInput:this.handleInput,
      onCheck: this.handleCheck
    }
    let node = createNode<TodoItemSimpleModel>(this.getUIContext(),builderData,this.wrapBuilder);

    this.myNodeController = node
  }
  @Builder
  sheetTitleBuilder(){
    Text(this.sheetTitle).fontSize(20)
  }
  @Builder
  submitBtnBuilder(){
    SymbolGlyph($r('sys.symbol.checkmark')).fontSize(30)
      .onClick(()=>{
        this.handleSubmit()
      })
  }
  build() {

    Column({space: 15}){
      CustomTitleBar({
        onBackPress:()=>{
          this.onCancel()
        },
        title:()=>{
          //
          this.sheetTitleBuilder()
        },
        extraContent:()=>{
          this.submitBtnBuilder()
        }
      }).padding({left: 15,right: 15})
      Row(){
        NodeContainer(this.myNodeController)
      }.rowAttr()

      Row(){
        Text('时间提醒')
        TextInput(
          {
            text:this.time?formatDate(this.time):null,
            placeholder:'请选择提醒时间',
            controller:this.textController
          })
          .focusable(false)
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .onClick(()=>{
            this.openDateTimePicker((v)=>{
              this.time = v
            })
          }).padding({right: 15})
        if(this.time){
          SymbolGlyph($r('sys.symbol.xmark_circle'))
            .fontSize(16).onClick(()=>{
            this.textController.deleteText()
            this.time = null
          })
        }else {

          SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(20)
        }
      }
      .rowAttr()


      Row(){
        Text('位置提醒')
        TextInput({placeholder:'请选择提醒位置',}).focusable(false).layoutWeight(1).backgroundColor(Color.Transparent)
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(20)
      }.rowAttr()

      Row(){
        Text('备注')
        TextInput({text: $$this.memo,placeholder:'请输入备注',}).layoutWeight(1).backgroundColor(Color.Transparent)
      }.rowAttr()


    }
    .width('100%')
    .height('100%')
  }
}