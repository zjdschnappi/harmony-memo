import { EmojiData, EmojiModel } from "../../model/Memo";
import { EmojiDetail } from "./EmojiDetail";
// 表情键盘
@ComponentV2
export struct EmojiSelectView {
  @Param onEmojiSelect:(item:Resource)=>void=()=>{}
  private msgFontSize: number = 0;
  @Local show:boolean = false;

  @Builder
  customBuilder(){
    Grid() {
      // TODO: 性能知识点：使用ForEach组件循环渲染数据
      ForEach(EmojiData, (item: EmojiModel) => {
        GridItem() {
          // 表情明细组件
          EmojiDetail({
            EmojiItem: item,
            msgFontSize: this.msgFontSize,

          })
        }
        .onClick(()=>{
          this.onEmojiSelect(item.imgSrc)

        })
        .id('faceGridId')
      })
    }
    .maxCount(6)
    .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr") // 分成6份
    .rowsGap(5)
    .margin({top:60,bottom:10})
    .padding({left: 10,right :10})
    .width('100%')
  }

  build() {

    SymbolGlyph($r('sys.symbol.face')).fontSize(30)
      .onClick(()=>{
        this.show = true
      })
      .bindSheet($$this.show, this.customBuilder(), {
        height:SheetSize.FIT_CONTENT,
        backgroundColor: Color.White,
        onWillAppear: () => {
          console.log("BindSheet onWillAppear.");
        },
        onAppear: () => {
          console.log("BindSheet onAppear.");
        },
        onWillDisappear: () => {
          console.log("BindSheet onWillDisappear.");
        },
        onDisappear: () => {
          console.log("BindSheet onDisappear.");
        }
      })

  }
}