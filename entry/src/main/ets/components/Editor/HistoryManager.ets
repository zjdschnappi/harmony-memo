import { EditorCommand } from './Command'
export class EditorHistoryManager {
  private undoStack: EditorCommand[] = [];
  private redoStack: EditorCommand[] = [];
  private maxHistorySize: number = 100;
  private controller: RichEditorController;

  constructor(controller: RichEditorController) {
    this.controller = controller;
  }

  // 执行新命令
  async executeCommand(command: EditorCommand): Promise<void> {
    command.execute(this.controller);


    this.undoStack.push(command);


    // 清空重做栈
    this.redoStack = [];

    // 控制历史记录大小
    this.trimHistory();
  }

  async undo(): Promise<void> {
    if (this.undoStack.length === 0) return;

    const command = this.undoStack.pop()!;
    command.undo(this.controller);
    this.redoStack.push(command);
  }

  async redo(): Promise<void> {
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

  canUndo(): boolean {
    return this.undoStack.length > 0;
  }

  canRedo(): boolean {
    return this.redoStack.length > 0;
  }

  clearHistory(): void {
    this.undoStack = [];
    this.redoStack = [];
  }
}