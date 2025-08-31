import { Editor } from '../components/Editor'
import MemoViewModel from '../viewmodel/MemoViewModel'
import { IMemoContentItem } from "../model/Memo";
import {IMemoRouteParam} from '../types'
@Component
export struct MemoDetailView {
  @Prop isEnabled:boolean = true
  @State @Watch('titleChange') memoTitle:string = '';
  onGetTitle?:(title:string)=>void = () =>{}
  editorOptions: RichEditorOptions = { controller: new RichEditorController() };
  pageParams:IMemoRouteParam ={id:'-1'}

  titleChange(){
    this.onGetTitle?.(this.memoTitle)
  }
  handleGetDetail() {
    let px2vp = this.getUIContext().px2vp
    MemoViewModel.getDetailById(this.pageParams.id).then((data) => {

      this.memoTitle = data?.title || ''
      data?.content?.forEach((item: IMemoContentItem) => {
        if (typeof (item as RichEditorImageSpanResult).valueResourceStr != 'undefined') {
          let content = item as RichEditorImageSpanResult

          this.editorOptions.controller.addImageSpan(content.valueResourceStr, {
            imageStyle: {
              size: content.imageStyle.size.map(item => px2vp(item)) as [Dimension, Dimension],
              layoutStyle: content.imageStyle.layoutStyle,
              verticalAlign: content.imageStyle.verticalAlign,
              objectFit: content.imageStyle.objectFit
            }
          })
        } else {
          let content = item as RichEditorTextSpanResult
          this.editorOptions.controller.addTextSpan(content.value, {
            style: {
              fontColor: content.textStyle.fontColor,
              fontWeight: content.textStyle.fontWeight == 9 ? FontWeight.Bold : FontWeight.Normal,
              fontSize: content.textStyle.fontSize,
              fontStyle: content.textStyle.fontStyle,
              decoration: content.textStyle.decoration,
              fontFeature: content.textStyle.fontFeature

            },
            paragraphStyle: content.paragraphStyle
          })
        }
      })
    })
  }

  aboutToAppear(): void {
    this.handleGetDetail()
  }
  build(){

    Column(){
      TextInput({
        placeholder:'标题',
        text: this.memoTitle
      })

        .focusable(this.isEnabled)
        .placeholderFont({
          size: 30
        })



        .caretColor(Color.Orange)
        .fontSize(30)
        .backgroundColor(Color.Transparent)
      Editor({editorOptions:this.editorOptions,showToolBar:this.isEnabled,isFocusable:this.isEnabled}).layoutWeight(1)
    }
  }
}






































