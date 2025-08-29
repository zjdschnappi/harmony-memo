import { Editor } from '../components/Editor'
import MemoViewModel from '../viewmodel/MemoViewModel'
import { IMemoContentItem } from "../model/Memo";
import {IMemoRouteParam} from '../types'
@Component
export struct MemoDetailView {
  @Prop isEnabled:boolean = true
  @State memoTitle:string = '';
  controller: RichEditorController = new RichEditorController();
  pageParams:IMemoRouteParam ={id:'-1'}
  handleGetDetail() {
    let px2vp = this.getUIContext().px2vp
    MemoViewModel.getDetailById(this.pageParams.id).then((data) => {

      this.memoTitle = data?.title || ''
      data?.content?.forEach((item: IMemoContentItem) => {
        if (typeof (item as RichEditorImageSpanResult).valueResourceStr != 'undefined') {
          let content = item as RichEditorImageSpanResult

          this.controller.addImageSpan(content.valueResourceStr, {
            imageStyle: {
              size: content.imageStyle.size.map(item => px2vp(item)) as [Dimension, Dimension],
              layoutStyle: content.imageStyle.layoutStyle,
              verticalAlign: content.imageStyle.verticalAlign,
              objectFit: content.imageStyle.objectFit
            }
          })
        } else {
          let content = item as RichEditorTextSpanResult
          this.controller.addTextSpan(content.value, {
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
  build(){

    Column(){
      TextInput({
        placeholder:'标题',
        text: this.memoTitle
      }).enabled(this.isEnabled)

        .placeholderFont({
          size: 30
        })

        .defaultFocus(true)
        .caretColor(Color.Orange)
        .fontSize(30)
        .backgroundColor(Color.Transparent)
      Editor({editorOptions:{controller:this.controller}}).layoutWeight(1).enabled(this.isEnabled)
    }
  }
}






































