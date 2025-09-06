/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { EmojiModel } from '../../model/Memo';

// 表情详细信息
@Component
export struct EmojiDetail {
  // 单个表情模型
  EmojiItem: EmojiModel | undefined = undefined;
  msgFontSize: number = 0;
  // popup状态
  @State isPopup: boolean = false;


  /**
   * popup表情详情弹框
   */
  @Builder
  popupBuilder() {
    Column() {
      Image(this.EmojiItem?.imgSrc)
        .width(30 * 2) // 2, 放大两倍
        .height(30 * 2) // 2, 放大两倍
        .id('popupImage')
      Text(this.EmojiItem?.meaning)
    }
    .justifyContent(FlexAlign.SpaceAround)
    .padding(15)
  }

  build() {
    Image(this.EmojiItem!.imgSrc)
      .width(30)
      .height(30)
      .id('detailId')
      .draggable(false)
      .gesture(
        // TODO 知识点：长按弹出表情明细
        LongPressGesture()
          .onAction(() => {
            this.isPopup = true;
          })
          .onActionEnd(() => {
            this.isPopup = false;
          })
      )
      .bindPopup(this.isPopup, {
        // TODO 知识点：使用bindPopup弹出表情明细
        builder: this.popupBuilder, onStateChange: (e) => {
          if (!e.isVisible) {
            this.isPopup = false;
          }
        }
      })
  }
}