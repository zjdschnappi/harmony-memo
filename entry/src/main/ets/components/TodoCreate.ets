import { formatDate } from "../utils/DateUtil";
import { dateTimePickerDialog } from "./DateTimePicker/DateTimePickerDialog";
import { DateTimePickerParam, TimeFormat } from "./DateTimePicker/DateTimePickerInterface";

@Extend(Row)
function rowAttr(){
  .width('90%')
  .padding({top:10,bottom:10,left:15,right:15})
  .backgroundColor(Color.White)
  .borderRadius(15)
}

@ComponentV2
export struct TodoCreate {
  @Local title:string='';
  @Local memo:string='';
  @Local time:string|null = null;

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
  build() {

    Column({space: 15}){

      Row(){
        Text('待办事项')
        TextInput({text: this.title,placeholder:'请输入待办事项'}).layoutWeight(1).backgroundColor(Color.Transparent)
      }.rowAttr()

      Row(){
        Text('时间提醒')
        TextInput({text:$$this.time,placeholder:'请选择提醒时间'}).focusable(false).layoutWeight(1).backgroundColor(Color.Transparent)
          .onClick(()=>{
            this.openDateTimePicker((v)=>{
              //
              this.time = formatDate(v)
            })
          }).padding({right: 15})
        if(this.time){
          SymbolGlyph($r('sys.symbol.xmark_circle')).fontSize(16).onClick(()=>{
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
        TextInput({text: this.memo,placeholder:'请输入备注',}).layoutWeight(1).backgroundColor(Color.Transparent)
      }.rowAttr()


    }
    .margin({top: 15})
    .width('100%')
    .height('100%')
  }
}