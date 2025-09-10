import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  DateIndex,
  DateTimePickerData,
  DateTimePickerOption,
  DateTimePickerParam,
  DateTimePickerStyle,
  TimeFormat
} from './DateTimePickerInterface';
import { DATE_TIME_RANGE } from '../../utils/DateUtil';

function isVisibility(dateIndex: DateIndex, timeFormat?: TimeFormat): Visibility {
  let format: DateIndex[] = [DateIndex.DAY, DateIndex.HOURS, DateIndex.MINUTES, DateIndex.SECOND];
  return (dateIndex <= format[timeFormat ?? TimeFormat.MINUTES]) ? Visibility.Visible : Visibility.None;
}
function vibrate(){
  try {
      vibrator.isSupportEffect('haptic.notice.success', (err: BusinessError, state: boolean) => {
        if (err) {
          console.error(`Failed to query effect. Code: ${err.code}, message: ${err.message}`);
          return;
        }
        console.info('Succeed in querying effect');
        if (state) {
          try {
            vibrator.startVibration({
              type: 'preset',
              effectId: 'haptic.notice.success',
              count: 1,
            }, {
              usage: 'notification' // 根据实际选择类型归属不同的开关管控
            }, (error: BusinessError) => {
              if (error) {
                console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
                return;
              }
              console.info('Succeed in starting vibration');

            });
          } catch (err) {
            let e: BusinessError = err as BusinessError;
            console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
          }
        }
      })
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
}

@Observed
class PickerClass {
  @Track range: string[] = []
  @Track selected: number = 0
  @Track dateIndex: DateIndex = DateIndex.YEAR
  @Track option?: DateTimePickerOption
  callback = (dateIndex: DateIndex, value: string | string[], index: number | number[]) => {
  }
}

@Builder
function customPicker(picker: PickerClass) {
  TextPicker({ range: picker.range, selected: picker.selected })
    .layoutWeight(1)
    .canLoop(picker.option?.isLoop ?? false)
    .visibility(isVisibility(picker.dateIndex, picker.option?.timeFormat))
    .onChange((value: string | string[], index: number | number[]) => {
      picker.callback(picker.dateIndex, value, index)
      vibrate()
    })
}

@Builder
export function dateTimePickerBuilder(param: DateTimePickerParam) {
  DateTimePicker({
    data: param.data,
    option: param.option,
    style: param.style
  })
}

@Component
export struct DateTimePicker {
  @Prop @Require data: DateTimePickerData;
  @Prop @Watch('onChangedOption') option: DateTimePickerOption | undefined;
  @Prop style: DateTimePickerStyle | undefined;
  @State @Watch('onChangedSelectDate') selectDate: Date = new Date();
  @State yearRange: string[] = [];
  @State monthRange: string[] = [];
  @State dayRange: string[] = [];
  @State currentYear: number = this.selectDate.getFullYear();
  @State currentMonth: number = this.selectDate.getMonth() + 1;
  @State currentDay: number = this.selectDate.getDate();
  @State monthIndex: number = this.selectDate.getMonth();
  @State dayIndex: number = this.selectDate.getDate() - 1;

  aboutToAppear(): void {
    DATE_TIME_RANGE.setYearRange(this.data.startYear, this.data.endYear);
    this.selectDate = this.data.selectedDate ?? this.selectDate;
    this.onChangedOption();
  }

  onChangedSelectDate() {
    this.data.resultCb(this.selectDate);
  }

  onChangedOption() {
    this.yearRange = DATE_TIME_RANGE.yearRange();
    this.monthRange = DATE_TIME_RANGE.monthRange(this.currentYear);
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);

    this.monthIndex = this.currentMonth - 1;
    this.dayIndex = this.currentDay - 1;
  }

  updateSelectedDate = (dateIndex: DateIndex, value: string | string[], index: number | number[]) => {
    if (Array.isArray(value) || Array.isArray(index)) {
      return;
    }

    switch (dateIndex) {
      case DateIndex.YEAR:
        this.dealSelectedYear(value, index);
        break;
      case DateIndex.MONTH:
        this.dealSelectedMonth(value, index);
        break;
      case DateIndex.DAY:
        this.dealSelectedDay(value, index);
        break;
      default:
        this.dealSelectedTime(dateIndex, value, index);
        break;
    }
  }

  dealSelectedYear(value: string, index: number) {
    this.currentYear = Number(value.slice(0, -1));
    this.monthRange = DATE_TIME_RANGE.monthRange(this.currentYear);
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);
    this.updateDateTime();
  }

  dealSelectedMonth(value: string, index: number) {
    this.currentMonth = Number(value.slice(0, -1));
    this.monthIndex = index;
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);
    this.updateDateTime();
  }

  dealSelectedDay(value: string, index: number) {
    this.currentDay = index + 1;
    this.dayIndex = index;
    this.updateDateTime();
  }

  dealSelectedTime(dateIndex: DateIndex, value: string, index: number) {
    switch (dateIndex) {
      case DateIndex.HOURS:
        this.selectDate.setHours(index);
        break;
      case DateIndex.MINUTES:
        this.selectDate.setMinutes(index);
        break;
      case DateIndex.SECOND:
        this.selectDate.setSeconds(index);
        break;
      default:
        break;
    }
  }

  updateDateTime() {
    this.updateSolarDate();
  }

  updateSolarDate() {
    this.selectDate = new Date(
      this.currentYear,
      this.currentMonth - 1,
      this.currentDay,
      this.selectDate.getHours(),
      this.selectDate.getMinutes(),
      this.selectDate.getSeconds()
    );
  }

  build() {
    Row() {
      customPicker({
        // 年
        range: this.yearRange,
        selected: this.currentYear - DATE_TIME_RANGE.getStartYear(),
        dateIndex: DateIndex.YEAR,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 月
        range: this.monthRange,
        selected: this.monthIndex,
        dateIndex: DateIndex.MONTH,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 日
        range: this.dayRange,
        selected: this.dayIndex,
        dateIndex: DateIndex.DAY,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 时
        range: DATE_TIME_RANGE.hourRange(),
        selected: this.selectDate.getHours(),
        dateIndex: DateIndex.HOURS,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 分
        range: DATE_TIME_RANGE.minutesRange(),
        selected: this.selectDate.getMinutes(),
        dateIndex: DateIndex.MINUTES,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 秒
        range: DATE_TIME_RANGE.secondsRange(),
        selected: this.selectDate.getSeconds(),
        dateIndex: DateIndex.SECOND,
        callback: this.updateSelectedDate,
        option: this.option
      })
    }
    .backgroundColor(this.style?.backgroundColor ? this.style.backgroundColor : Color.Transparent)
    .borderColor(this.style?.borderColor ? this.style.borderColor : Color.Transparent)
    .borderWidth(this.style?.borderWidth ? this.style.borderWidth : 0)
    .borderRadius(this.style?.borderRadius ? this.style.borderRadius : 0)
    .margin(this.style?.margin ? this.style.margin : 0)
  }
}