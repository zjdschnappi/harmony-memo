// Index.ets
import { AnimateCallback, CustomTransition } from '../customTransition/CustomNavigationUtils';

const TAG: string = 'Index';

@Entry
@Component
struct Index {
  @Provide pagePathStackInfos: NavPathStack = new NavPathStack();
  // 允许进行自定义转场的页面名称
  private allowedCustomTransitionFromPageName: string[] = ['Home'];
  private allowedCustomTransitionToPageName: string[] = ['MemoDetail'];

  aboutToAppear(): void {
    this.pagePathStackInfos.pushPath({ name: 'Home' },false);
  }

  private isCustomTransitionEnabled(fromName: string, toName: string): boolean {
    // 点击和返回均需要进行自定义转场，因此需要分别判断
    if ((this.allowedCustomTransitionFromPageName.includes(fromName)
      && this.allowedCustomTransitionToPageName.includes(toName))
      || (this.allowedCustomTransitionFromPageName.includes(toName)
        && this.allowedCustomTransitionToPageName.includes(fromName))) {
      return true;
    }
    return false;
  }

  build() {
    Navigation(this.pagePathStackInfos)
      .hideNavBar(true)
      .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
        if ((!from || !to) || (!from.name || !to.name)) {
          return undefined;
        }

        // 通过from和to的name对自定义转场路由进行管控
        if (!this.isCustomTransitionEnabled(from.name, to.name)) {
          return undefined;
        }

        // 需要对转场页面是否注册了animation进行判断，来决定是否进行自定义转场
        let fromParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(from.index);
        let toParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(to.index);
        if (!fromParam.animation || !toParam.animation) {
          return undefined;
        }

        // 一切判断完成后，构造customAnimation给系统侧调用，执行自定义转场动画
        let customAnimation: NavigationAnimatedTransition = {
          onTransitionEnd: (isSuccess: boolean) => {
            console.info(TAG, `current transition result is ${isSuccess}`);
          },
          timeout: 2000,
          transition: (transitionProxy: NavigationTransitionProxy) => {
            console.info(TAG, 'trigger transition callback');
            if (fromParam.animation) {
              fromParam.animation(operation == NavigationOperation.PUSH, true, transitionProxy);
            }
            if (toParam.animation) {
              toParam.animation(operation == NavigationOperation.PUSH, false, transitionProxy);
            }
          }
        };
        return customAnimation;
      })
  }
}