import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
@ComponentV2
export struct SharePanel {
  @Local panelOpen:boolean = false

  @Builder
  panelBuilder(){
    Row({space:20}){
      Column({space: 10}){
        Text(){
          SymbolSpan($r('sys.symbol.share'))
            .fontSize('30vp')
        }
        .borderRadius('50%')
        .width(50)
        .height(50)
        .backgroundColor('#dfdfdf')
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
        Text($r('app.string.system_share')).fontSize(10)
      }
      .onClick(()=>{
        this.handelSystemShare()
      })

    }
    .width('100%')
    .padding({left:10,right:10})
  }
   async handelSystemShare(): Promise<void> {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleImage.jpg';
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.jpg', utd.UniformDataType.IMAGE);
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: 'Picture Title',
      description: 'Picture Description',
    });
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.BATCH,
    }).then(() => {

    }).catch((error: BusinessError) => {

    });
  }
  build() {
    SymbolGlyph($r('sys.symbol.share'))
      .fontSize(30)
      .bindSheet($$this.panelOpen, this.panelBuilder,{
        height:150,
        title:{
          title: '分享给朋友',
        },


      })
      .onClick(()=>{
        this.panelOpen = !this.panelOpen
      })
  }
}