import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { cameraPicker as picker,camera } from '@kit.CameraKit';

interface IItem{
  icon: Resource;
  text: string;
  onClick:()=>void
}
@ComponentV2
export struct PhotoSelectView {
  @Local show:boolean = false
  @Param onImgSelect:(item:string[])=>void=()=>{}

  getList(){
    let list:IItem[] = [
      {
        icon: $r('sys.symbol.picture'),
        text:'图库',
        onClick:()=>{
          //
          this.show = false
          this.openGallery()
        }
      },
      {
        icon: $r('sys.symbol.camera'),
        text:'拍照',
        onClick:()=>{
          //
          this.show = false
          this.takePhoto()
        }
      }
    ]
    return list
  }
  async openGallery() {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1; // 单选模式

      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select(photoSelectOptions);
      if (result.photoUris.length > 0) {
        // 显示选中图片到Image组件
        this.onImgSelect(result.photoUris)
      }
    } catch (err) {
      console.error('选择图库失败:', err);
    }
  }
  async takePhoto(){
    try {
      let pickerProfile: picker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: picker.PickerResult = await picker.pick(getContext(this),
        [picker.PickerMediaType.PHOTO, picker.PickerMediaType.VIDEO], pickerProfile);

      this.onImgSelect([pickerResult.resultUri])

    } catch (error) {
      let err = error as BusinessError;
      console.error(`the pick call failed. error code: ${err.code}`);
    }
  }
  @Builder
  customBuilder(){
    Column(){
      List(){
        ForEach(this.getList(),(item:IItem)=>{
          ListItem(){
            Row(){
              SymbolGlyph(item.icon).fontSize(30).width(30)
              Text(item.text).layoutWeight(1).padding({left:10}).border({
                width:{
                  bottom:1,

                },
                color: '#fdfdfd'
              })
              Blank().width(30)
            }
          }.padding(10).width('100%').onClick(()=>{
            item.onClick()
          })
        })
      }
    }.width(180)
  }
  build(){


    SymbolGlyph($r('sys.symbol.camera')).fontSize(30).onClick(()=>{
      this.show = true
    }).bindPopup(this.show,{
      builder: this.customBuilder,
      placement: Placement.Top,
      onStateChange:(v)=>{
        this.show = v.isVisible
      }
    })
  }
}