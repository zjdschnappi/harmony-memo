
import { EmojiSelectView } from "./EmojiSelectView";
import { PhotoSelectView } from "./PhotoSelectView";
import { TextFormatToolView } from "./TextFormatToolView";
import EventManager , { EventTypes } from '../../utils/EventManager'
import { InsertImgCommand } from "./Command";
import { EditorHistoryManager } from "./HistoryManager";

@ComponentV2
export struct Editor {
  @Param editorOptions: RichEditorOptions = { controller: new RichEditorController() };

  @Param isFocusable: boolean = true
  @Param showToolBar:boolean = true
  @Consumer() historyManager:EditorHistoryManager = new EditorHistoryManager(this.editorOptions.controller)


  build(){

    Column(){

      RichEditor(this.editorOptions)

        .placeholder('写点什么吧...')
        .height('100%')
        .caretColor(Color.Orange)
        .focusable(this.isFocusable)
        .onReady(() => {

          //
        })
        .aboutToIMEInput((v)=>{
          EventManager.emit(EventTypes.EDITOR_ABOUT_TO_INPUT,{data:v})
          return false
        })
        .layoutWeight(1)
        .onSelectionChange(v=>{

          EventManager.emit(EventTypes.EDITOR_SELECTION_CHANGE,{data:v})
        })
      if(this.showToolBar){
        Row(){
          List({space:20}){
            ListItem(){
              TextFormatToolView({controller: this.editorOptions.controller})
            }
            ListItem(){
              EmojiSelectView({
                onEmojiSelect:(url)=>{
                  let command = new InsertImgCommand(url,{
                    imageStyle: {
                      size: [30, 30], // 3.2 调整表情在输入框中的尺寸
                      verticalAlign: ImageSpanAlignment.CENTER,
                      layoutStyle: { margin: {right:1} }
                    }
                  })
                  this.historyManager.executeCommand(command)
                }
              })
            }
            ListItem(){
              PhotoSelectView({onImgSelect:(urls)=>{
                let command = new InsertImgCommand(urls[0],{
                  imageStyle: {
                    verticalAlign: ImageSpanAlignment.CENTER,
                    layoutStyle: { margin: {right:1} }
                  }
                })
                this.historyManager.executeCommand(command)
              }})
            }
          }.listDirection(Axis.Horizontal).alignListItem(ListItemAlign.Center).padding({left:15,right:15})
        }.width('100%').height(40)
      }

    }.height('100%')
  }
}