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
