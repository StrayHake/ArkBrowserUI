// entryability/EntryAbility.ets
import { UIAbility } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'                // ← 必须用这个
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0100
const NAVIGATION_HEIGHT = 48                     // 你想要的装饰高度，可 0

export default class EntryAbility extends UIAbility {

  onWindowStageCreate(stage: window.WindowStage): void {
    /* 1. 先加载页面 */
    stage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        hilog.error(DOMAIN, 'EntryAbility',
          `loadContent failed: ${err.code} ${err.message}`)
        return
      }
      /* 2. 页面成功 → 关闭系统 Decor & Caption */
      this.hideTitleBar(stage)
    })
  }

  /* ───── 精简版 hideTitleBar ───── */
  private async hideTitleBar(stage: window.WindowStage) {
    try {
      const win = await stage.getMainWindow()
      /* SystemCapability.Window.SessionManager 是否可用？*/
      if (!canIUse('SystemCapability.Window.SessionManager')) {
        hilog.error(DOMAIN, 'EntryAbility', 'SessionManager not supported')
        return
      }
      await win.setWindowDecorVisible(false)          // 隐藏标题栏+边框
      await win.setWindowDecorHeight(NAVIGATION_HEIGHT)  // 裁掉残余空高
      hilog.info(DOMAIN, 'EntryAbility', 'System title bar hidden')
    } catch (e) {
      const err = e as BusinessError
      hilog.error(DOMAIN, 'EntryAbility',
        `hideTitleBar failed: ${err.code} ${err.message}`)
    }
  }
}
