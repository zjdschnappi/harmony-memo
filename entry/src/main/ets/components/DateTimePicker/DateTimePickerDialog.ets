/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the ""License"");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an ""AS IS"" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import { ComponentContent, promptAction } from '@kit.ArkUI';
import { DateTimePickerParam, TimeFormat } from './DateTimePickerInterface';
import { DateTimePicker } from './DateTimePicker';

interface DateTimePickerDialogConfig {
  context: UIContext
  content: ComponentContent<ESObject>
}

interface DateTimePickerDialogParam {
  txt: ResourceStr
  node: number
  param: DateTimePickerParam
}

let mapContext: Map<number, DateTimePickerDialogConfig> = new Map();

@Builder
function dateTimePickerDialogBuilder(param: DateTimePickerDialogParam) {
  DateTimePickerDialogComponent({
    node: param.node,
    param: param.param,
    txt: param.txt
  })
}

@Extend(Button)
function buttonStyles() {
  .width('50%')
  .layoutWeight(1)
  .fontColor('#FF007DFF')
  .backgroundColor(Color.Transparent)
}

@Component
struct DateTimePickerDialogComponent {
  @Prop txt: ResourceStr;
  @Prop node: number;
  @Prop param: DateTimePickerParam;
  @State selectDate: Date = this.param.data.selectedDate!
  private timeFormat: TimeFormat = TimeFormat.MINUTES;
  updateSelectData = (date: Date) => {
    this.selectDate = date;
  }

  aboutToAppear(): void {
    this.timeFormat = this.param.option?.timeFormat ?? TimeFormat.MINUTES;
  }

  closeDialog() {
    if (mapContext.has(this.node)) {
      let config = mapContext.get(this.node);
      config?.context.getPromptAction().closeCustomDialog(config.content);
      mapContext.delete(this.node);
    }
  }

  build() {
    Column() {
      Text(this.txt)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 16 })

      DateTimePicker({
        data: {
          startYear: this.param.data.startYear,
          endYear: this.param.data.endYear,
          selectedDate: this.param.data.selectedDate,
          resultCb: this.updateSelectData,
        },
        option: this.param.option,
        style: undefined
      })
        .height(200)
        .width('85%')


      Row({ space: 8 }) {
        Button($r('app.string.cancel'))
          .buttonStyles()
          .fontSize(16)
          .fontColor($r('sys.color.black'))
          .onClick(() => {
            this.closeDialog();
          })
        Divider()
          .vertical(true)
          .height(30)
        Button($r('app.string.confirm'))
          .buttonStyles()
          .fontSize(16)
          .fontColor('rgb(10, 89, 247)')
          .onClick(() => {
            this.param.data.resultCb(this.selectDate);
            this.closeDialog();
          })
      }
      .width('100%')
      .height(60)
      .margin({ top: 13 })
      .padding(8)
    }
    .width('91%')
    .height('42%')
    .backgroundColor(this.param.style?.backgroundColor ? this.param.style.backgroundColor : Color.White)
    .borderRadius(15) // 设置圆角边框
    .margin({ top: 80 })
  }
}

export function dateTimePickerDialog(uiContext: UIContext, param: DateTimePickerParam, txt: ResourceStr,
  dialogOptions?: promptAction.BaseDialogOptions) {
  let now: number = Date.now();
  let contentNode = new ComponentContent(uiContext, wrapBuilder(dateTimePickerDialogBuilder), {
    node: now,
    param: param,
    txt: txt
  } as DateTimePickerDialogParam);
  uiContext.getPromptAction().openCustomDialog(contentNode, dialogOptions);
  mapContext.set(now, { context: uiContext, content: contentNode });
}