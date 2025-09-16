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
  @Local title:string='';
  @Local memo:string='';
  @Local time:Date|null = null;
  @Local myNodeController: ItemNode<TodoItemSimpleModel> | undefined = new ItemNode(false);
  @Param onSubmitSuccess:()=>void = ()=>{}
  @Param detailData: ITodoDetailModel|null = null
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
  handlePublishCalendar(eventId:number){
    if(!this.time) return
    // Index.ets
    const event: calendarManager.Event = {
      // 日程标题
      title: this.title,
      // 日程类型，不推荐三方开发者使用calendarManager.EventType.IMPORTANT，重要日程类型不支持一键服务跳转功能及无法自定义提醒时间
      type: calendarManager.EventType.NORMAL,
      // 日程开始时间
      startTime: this.time!.getTime(),
      // 日程结束时间
      endTime: this.time!.getTime() + 60 * 60 * 1000,
      // 距开始时间提前10分钟提醒
      reminderTime: [5],

    };

    this.calendar?.addEvent(event).then((data: number) => {
      console.info(`Succeeded in adding event, id -> ${data}`);
      eventId = data;
    }).catch((err: BusinessError) => {
      console.error(`Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
    });

    //todo
    // 待办完成的时候，待办删除的时候，都要移除日程
  }
  private handleSubmit= async ()=>{
    try{
      let id = await TodoViewModel.create({
        title:this.title,
        dueTime: this.time?formatDate(this.time):undefined,
        memo: this.memo
      })

      EventManager.emit(EventTypes.FETCH_TODO_LIST)
      this.handlePublishCalendar(id)
    }
    catch(e) {
      console.log('222')
    }

  }
  private handleInput=(v:string)=>{
    //
    this.title = v
  }
  @Monitor('detailData')
  handleDetailChange(){
    let item :TodoItemSimpleModel|null = null
    let data = this.detailData;
    if(data){
      item = new TodoItemSimpleModel(data?.id,data?.todoId,data?.title,data?.createdTime
        ,data?.modifiedTime,data.isCompleted,data?.priority,data?.dueTime,data?.location,data?.memo)
    }
    this.myNodeController?.update(true,item)
  }

  aboutToAppear(): void {
      // 新建自定义节点
    let builderData:ICreateItemNodeBuilderProp = {
      item:null,
      isExpand:true,
      onInput:this.handleInput
    }
    let  node = createNode<TodoItemSimpleModel>(this.getUIContext(),builderData,this.wrapBuilder);

    this.myNodeController = node
  }
  build() {

    Column({space: 15}){

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

      Button($r('app.string.confirm')).width('90%').backgroundColor(Color.Blue).onClick(()=>{
        this.handleSubmit()
      })

    }
    .margin({top: 15})
    .width('100%')
    .height('100%')
  }
}