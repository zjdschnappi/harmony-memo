import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { LoadingView } from './LoadingView';

@ComponentV2
export struct SharePanel {
  @Local panelOpen:boolean = false
  @Param targetViewComponentId:string=''
  @Local loadingView :LoadingView = new LoadingView()


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
        this.handleSystemShare()
      })

    }
    .width('100%')
    .padding({left:10,right:10})
  }
   async handleGetSnapshot():Promise<image.PixelMap>{
     const img = await this.getUIContext().getComponentSnapshot().get(this.targetViewComponentId)
     return img
   }
   async handleSystemShare(): Promise<void> {

    try {
      this.loadingView.showLoading('')
      const uiContext: UIContext = this.getUIContext();
      const contextFaker: Context = uiContext.getHostContext() as Context;
      const pixelMap =await this.handleGetSnapshot()
      let filePath = contextFaker.cacheDir + '/exampleImage.png';
      let uri = fileUri.getUriFromPath(filePath); // 转换沙箱路径为URI

      let imageFile = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      // 绘制内容写进图片文件里
      await image.createImagePacker()
        .packToFile(pixelMap, imageFile.fd, {
          format: 'image/png',
          quality: 80,
        })
      this.loadingView.hide()
      let shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.IMAGE,
        uri: uri,
        title: 'Picture Title',
        description: 'Picture Description',
      });
      let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
      controller.show(context, {
        previewMode: systemShare.SharePreviewMode.DETAIL,
        selectionMode: systemShare.SelectionMode.BATCH,
      }).then(()=>{
        this.panelOpen = false
      })
    }
    catch (e){
      this.loadingView.hide()
      console.log('systemshare系统分享',JSON.stringify(e))
    }

  }
  build() {
    SymbolGlyph($r('sys.symbol.share'))
      .fontSize(30)
      .bindSheet($$this.panelOpen, this.panelBuilder,{
        height:150,
        title:{
          title: '分享给朋友',
        }

      })
      .onClick(()=>{
        this.panelOpen = !this.panelOpen
      })
  }
}