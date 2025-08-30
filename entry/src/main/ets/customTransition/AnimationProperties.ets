// AnimationProperties.ets
// 一镜到底转场动画封装
import { curves, UIContext } from '@kit.ArkUI';
import { RectInfoInPx } from '../utils/ComponentAttrUtils';
import { WindowUtils } from '../utils/WindowUtils';
import { MemoItemNode } from '../components/MemoItemNode';

const TAG: string = 'AnimationProperties';

const DEVICE_BORDER_RADIUS: number = 34;
const DEFAULT_COLOR = '#fff'
// 将自定义一镜到底转场动画进行封装，其他界面也需要做自定义一镜到底转场的话，可以直接复用，减少工作量
@Observed
export class AnimationProperties {
  public navDestinationBgColor: ResourceColor = DEFAULT_COLOR
  public translateX: number = 0;
  public translateY: number = 0;
  public scaleValue: number = 1;
  public clipWidth: Dimension = 0;
  public clipHeight: Dimension = 0;
  public radius: number = 0;
  public positionValue: number = 0;
  public showDetailContent: boolean = false;
  private uiContext: UIContext;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  public doAnimation(cardItemInfo_px: RectInfoInPx, isPush: boolean, isExit: boolean,
    transitionProxy: NavigationTransitionProxy, extraTranslateValue: number, prePageOnFinish: (node: MemoItemNode) => void, myNodeController: MemoItemNode | undefined): void {
    // 首先计算卡片的宽高与窗口宽高的比例
    let widthScaleRatio = cardItemInfo_px.width / WindowUtils.windowWidth_px;
    let heightScaleRatio = cardItemInfo_px.height / WindowUtils.windowHeight_px;
    let isUseWidthScale = widthScaleRatio > heightScaleRatio;
    let initScale: number = isUseWidthScale ? widthScaleRatio : heightScaleRatio;

    let initTranslateX: number = 0;
    let initTranslateY: number = 0;
    let initClipWidth: Dimension = 0;
    let initClipHeight: Dimension = 0;
    // 使得PageTwo卡片向上扩到状态栏
    let initPositionValue: number = -this.uiContext.px2vp(WindowUtils.topAvoidAreaHeight_px + extraTranslateValue);

    if (isUseWidthScale) {
      initTranslateX = this.uiContext.px2vp(cardItemInfo_px.left - (WindowUtils.windowWidth_px - cardItemInfo_px.width) / 2);
      initClipWidth = '100%';
      initClipHeight = this.uiContext.px2vp((cardItemInfo_px.height) / initScale);
      initTranslateY = this.uiContext.px2vp(cardItemInfo_px.top - ((this.uiContext.vp2px(initClipHeight) - this.uiContext.vp2px(initClipHeight) * initScale) / 2));
    } else {
      initTranslateY = this.uiContext.px2vp(cardItemInfo_px.top - (WindowUtils.windowHeight_px - cardItemInfo_px.height) / 2);
      initClipHeight = '100%';
      initClipWidth = this.uiContext.px2vp((cardItemInfo_px.width) / initScale);
      initTranslateX = this.uiContext.px2vp(cardItemInfo_px.left - (WindowUtils.windowWidth_px / 2 - cardItemInfo_px.width / 2));
    }

    // 转场动画开始前通过计算scale、translate、position和clip height & width，确定节点迁移前后位置一致
    console.info(TAG, 'initScale: ' + initScale + ' initTranslateX ' + initTranslateX +
      ' initTranslateY ' + initTranslateY + ' initClipWidth ' + initClipWidth +
      ' initClipHeight ' + initClipHeight + ' initPositionValue ' + initPositionValue);
    // 转场至新页面
    if (isPush && !isExit) {
      this.scaleValue = initScale;
      this.translateX = initTranslateX;
      this.clipWidth = initClipWidth;
      this.clipHeight = initClipHeight;
      this.translateY = initTranslateY;
      this.positionValue = initPositionValue;

      this.uiContext?.animateTo({
        curve: curves.interpolatingSpring(0, 1, 328, 36),
        onFinish: () => {
          if (transitionProxy) {
            transitionProxy.finishTransition();
          }
        }
      }, () => {
        this.scaleValue = 1.0;
        this.translateX = 0;
        this.translateY = 0;
        this.clipWidth = '100%';
        this.clipHeight = '100%';
        // 页面圆角与系统圆角一致
        this.radius = DEVICE_BORDER_RADIUS;
        this.showDetailContent = true;
      })

      this.uiContext?.animateTo({
        duration: 100,
        curve: Curve.Sharp,
      }, () => {
        // 页面由透明逐渐变为设置背景色
        this.navDestinationBgColor = DEFAULT_COLOR
      })

      // 返回旧页面
    } else if (!isPush && isExit) {

      this.uiContext?.animateTo({
        duration: 350,
        curve: Curve.EaseInOut,
        onFinish: () => {
          if (transitionProxy) {
            transitionProxy.finishTransition();
          }
          prePageOnFinish(myNodeController);
          // 自定义节点从PageTwo下树
          if (myNodeController != undefined) {
            myNodeController.onRemove();
          }
        }
      }, () => {
        this.scaleValue = initScale;
        this.translateX = initTranslateX;
        this.translateY = initTranslateY;
        this.radius = 0;
        this.clipWidth = initClipWidth;
        this.clipHeight = initClipHeight;
        this.showDetailContent = false;
      })

      this.uiContext?.animateTo({
        duration: 200,
        delay: 150,
        curve: Curve.Friction,
      }, () => {
        this.navDestinationBgColor = DEFAULT_COLOR
      })
    }
  }
}