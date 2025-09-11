// Index.ets
import { AnimateCallback, CustomTransition } from '../customTransition/CustomNavigationUtils';
import {DebugDB} from '@hadss/debug-db';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { calendarMgr } from '../entryability/EntryAbility';
import { calendarManager } from '@kit.CalendarKit';

const TAG: string = 'Index';

@Entry
@ComponentV2
struct Index {
  @Provider() pagePathStackInfos: NavPathStack = new NavPathStack();
  @Provider() calendar?:calendarManager.Calendar
  // 允许进行自定义转场的页面名称
  private allowedCustomTransitionFromPageName: string[] = ['Home'];
  private allowedCustomTransitionToPageName: string[] = ['MemoDetail'];


  initCalendar(){


    let calendar: calendarManager.Calendar | undefined = undefined;
    // 指定日历账户信息
    const calendarAccount: calendarManager.CalendarAccount = {
      // 日历账户名称
      name: '我的备忘录',
      // 日历账户类型
      type: calendarManager.CalendarType.LOCAL,
      // 日历账户显示名称，该字段如果不填，创建的日历账户在界面显示为空字符串。
      displayName: '我的备忘录'
    };
    // 日历配置信息
    const config: calendarManager.CalendarConfig = {
      // 打开日程提醒
      enableReminder: true,
      // 设置日历账户颜色
      color: '#aabbcc'
    };
    // 创建日历账户
    calendarMgr?.createCalendar(calendarAccount).then((data: calendarManager.Calendar) => {
      console.info(`Succeeded in creating calendar data->${JSON.stringify(data)}`);
      this.calendar = data;
      // 请确保日历账户创建成功后，再进行后续相关操作
      data.setConfig(config).then(() => {
        console.info(`Succeeded in setting config, data->${JSON.stringify(config)}`);
      }).catch((err: BusinessError) => {
        console.error(`Failed to set config. Code: ${err.code}, message: ${err.message}`);
      });
    }).catch((error: BusinessError) => {
      console.error(`Failed to create calendar. Code: ${error.code}, message: ${error.message}`);
    });

  }
  aboutToAppear(): void {
    this.pagePathStackInfos.pushPath({ name: 'Home' },false);
    DebugDB.initialize(getContext(this) as common.UIAbilityContext)
    this.initCalendar()
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