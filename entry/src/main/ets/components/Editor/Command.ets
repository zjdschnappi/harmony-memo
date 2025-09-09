// 1. 抽象命令基类
export abstract class EditorCommand {
  abstract execute(controller: RichEditorController)
  abstract undo(controller: RichEditorController)

}

// 2. 插入文本命令
export class InsertTextCommand extends EditorCommand {
  private text: string;
  private prevOffset:number|null = 0;
  private curOffset:number|null = 0
  private options:RichEditorTextSpanOptions

  constructor(text: string,options:RichEditorTextSpanOptions) {
    super();
    this.text = text;
    this.options = options

  }

  execute(controller: RichEditorController){
    // 移动到插入位置并插入文本
    this.prevOffset = controller.getCaretOffset()
    controller.addTextSpan(this.text,this.options);
    this.curOffset = controller.getCaretOffset()

  }

   undo(controller: RichEditorController) {
    // 计算要删除的范围
    const start = this.prevOffset;
    const end = this.curOffset

    // 删除插入的文本
    controller.deleteSpans({start:start,end:end});

    // 恢复原始光标位置
    controller.setCaretOffset(start);
  }

}

interface SpanTextStyle{
  start?:number,
  end?:number,
  style:RichEditorTextStyle
}

export class FormatTextCommand extends EditorCommand{
  private startOffset:number=0
  private endOffset:number=0
  private prevTextStyles:SpanTextStyle[] = []
  private prevStyle:RichEditorTextStyle={};
  private curStyle:RichEditorTextStyle={}
  private undoCallback?:()=>void = ()=>{}
  constructor(start:number=0,end:number=0,style:RichEditorTextStyle,undoCallback:()=>void = ()=>{}) {
    super();
    this.startOffset = start;
    this.endOffset = end;
    this.undoCallback = this.undoCallback
    this.curStyle = style
  }
  execute(controller: RichEditorController){
    if(this.startOffset<this.endOffset){
      let spans = controller.getSpans()
      spans.forEach((item)=> {
        let span = item as RichEditorImageSpanResult
        if (typeof span.imageStyle !== 'undefined') {
          //
        } else {
          let span = item as RichEditorTextSpanResult;

          this.prevTextStyles.push({
            start: span.spanPosition.spanRange?.[0],
            end:span.spanPosition.spanRange?.[1],
            style: span.textStyle
          })
        }
      })

      controller.updateSpanStyle({
        start:this.startOffset,
        end:this.endOffset,
        textStyle:this.curStyle
      })
    }else {
      this.prevStyle = controller.getTypingStyle()
      controller.setTypingStyle(this.curStyle)
    }


  }
  undo(controller: RichEditorController) {

    if(this.prevTextStyles.length){
      this.prevTextStyles?.forEach((item)=>{

        controller.updateSpanStyle({
          start: item.start,
          end: item.end,
          textStyle: item.style
        })
      })

    }else {
      controller.setTypingStyle(this.prevStyle)
    }
  }
}
