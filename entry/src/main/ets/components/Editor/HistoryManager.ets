import { EditorCommand } from './Command'
@ObservedV2
export class EditorHistoryManager {
  @Trace private undoStack: EditorCommand[] = [];
  @Trace private redoStack: EditorCommand[] = [];
  private maxHistorySize: number = 100;
  private controller: RichEditorController;

  constructor(controller: RichEditorController) {
    this.controller = controller;
  }

  // 执行新命令
  executeCommand(command: EditorCommand) {
    command.execute(this.controller);


    this.undoStack.push(command);


    // 清空重做栈
    this.redoStack = [];

    // 控制历史记录大小
    this.trimHistory();
  }

  undo(){
    if (this.undoStack.length === 0) return;

    const command = this.undoStack.pop()!;
    command.undo(this.controller);
    this.redoStack.push(command);
  }

  redo(){
    if (this.redoStack.length === 0) return;

    const command = this.redoStack.pop()!;
    command.execute(this.controller);
    this.undoStack.push(command);
  }

  private trimHistory(): void {
    if (this.undoStack.length > this.maxHistorySize) {
      this.undoStack.shift();
    }
  }
  @Computed
  get canUndo(): boolean {
    return this.undoStack.length > 0;
  }
  @Computed
  get canRedo(): boolean {
    return this.redoStack.length > 0;
  }

  clearHistory(): void {
    this.undoStack = [];
    this.redoStack = [];
  }
}