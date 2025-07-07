import { window } from '@kit.ArkUI'
import { picker } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'

import {MenuComponent, TabContextMenuComponent, MenuPosition} from '../components/menuComponent'
import {MessageDialogComponent, MessageType, Message} from '../components/dialogComponent'
import {getMainMenuData, getTabContextMenuData, MenuCallbacks, TabMenuCallbacks} from '../utils/menuUtil'

@Entry
@Component
struct Index {
  // @State buttonAnimationDuration: number = 150
  @State tabs: string[] = ['example 01']
  @State current: number = 0
  @State counter: number = 1
  @State tabWidth: number = 128 // 动态计算的tab宽度
  @State containerWidth: number = 0 // 容器宽度
  @State needScroll: boolean = false // 是否需要滚动
  @State showMenu: boolean = false // 是否显示菜单
  @State selectedFilePath: string = '' // 选中的文件路径
  @State showMessageDialog: boolean = false // 是否显示消息对话框
  @State currentMessage: Message = { type: MessageType.INFO, title: '', content: '' } // 当前消息
  @State showTabContextMenu: boolean = false // 是否显示Tab右键菜单
  @State contextMenuTabIndex: number = -1 // 右键菜单对应的Tab索引
  @State contextMenuPosition: MenuPosition = { x: 0, y: 0 } // 右键菜单位置

  private nextTitle(): string {
    this.counter += 1
    return `example ${String(this.counter).padStart(2, '0')}`
  }

  // 显示消息对话框
  private showMessage(type: MessageType, title: string, content: string): void {
    this.currentMessage = { type, title, content }
    this.showMessageDialog = true
  }

  // 计算tab宽度
  private calculateTabWidth(): void {
    if (this.containerWidth <= 0) return

    const minTabWidth = 128
    const maxTabWidth = 256
    const addButtonWidth = 32 // + 按钮宽度

    // 可用宽度 = 容器宽度 - + 按钮宽度 - 间距
    const availableWidth = this.containerWidth - addButtonWidth - 4 * this.tabs.length

    // 计算每个tab的理想宽度
    const idealWidth = (availableWidth / this.tabs.length)

    if (idealWidth >= minTabWidth) {
      // 如果理想宽度大于最小宽度，使用理想宽度（但不超过最大宽度）
      this.tabWidth = Math.min(idealWidth, maxTabWidth)
      this.needScroll = false
    } else {
      // 如果理想宽度小于最小宽度，使用最小宽度并启用滚动
      this.tabWidth = minTabWidth
      this.needScroll = true
    }
  }

  // 文件选择器 - 保存文件
  private async saveFile(): Promise<void> {
    try {
      const documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions()
      documentSaveOptions.newFileNames = ['untitled.txt']

      const documentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker()
      const result: string[] = await documentPicker.save(documentSaveOptions)

      if (result && result.length > 0) {
        this.selectedFilePath = result[0]
        this.showMessage(MessageType.SUCCESS, '保存成功', `文件已保存到: ${this.selectedFilePath}`)
      }
    } catch (error) {
      console.error('保存文件失败:', error)
      this.showMessage(MessageType.ERROR, '保存失败', '保存文件时发生错误，请重试')
    }
  }

  // 文件选择器 - 另存为
  private async saveAsFile(): Promise<void> {
    try {
      const documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions()
      documentSaveOptions.newFileNames = ['copy.txt']

      const documentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker()
      const result: string[] = await documentPicker.save(documentSaveOptions)

      if (result && result.length > 0) {
        this.selectedFilePath = result[0]
        this.showMessage(MessageType.SUCCESS, '另存为成功', `文件已另存为: ${this.selectedFilePath}`)
      }
    } catch (error) {
      console.error('另存为失败:', error)
      this.showMessage(MessageType.ERROR, '另存为失败', '另存为文件时发生错误，请重试')
    }
  }

  // 文件选择器 - 打开文件
  private async openFile(): Promise<void> {
    try {
      const documentSelectOptions: picker.DocumentSelectOptions = new picker.DocumentSelectOptions()
      documentSelectOptions.maxSelectNumber = 1

      const documentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker()
      const result: string[] = await documentPicker.select(documentSelectOptions)

      if (result && result.length > 0) {
        this.selectedFilePath = result[0]
        this.showMessage(MessageType.SUCCESS, '打开成功', `已打开文件: ${this.selectedFilePath}`)
      }
    } catch (error) {
      console.error('打开文件失败:', error)
      this.showMessage(MessageType.ERROR, '打开失败', '打开文件时发生错误，请重试')
    }
  }

  // 退出应用
  private exitApp(): void {
    try {
      // 使用新的API替代已弃用的getContext
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
      window.getLastWindow(context)
        .then((windowClass: window.Window) => {
          windowClass.destroyWindow()
        })
        .catch((error: BusinessError) => {
          console.error('退出应用失败:', error)
        })
    } catch (error) {
      console.error('退出应用失败:', error)
    }
  }

  // 新建文件
  private addNewTab(): void {
    this.tabs.push(this.nextTitle())
    this.current = this.tabs.length - 1
    this.calculateTabWidth()
    this.showMessage(MessageType.SUCCESS, '新建成功', '已创建新文件')
  }

  // Tab右键菜单操作
  private closeLeftTabs(index: number): void {
    if (index > 0) {
      const removedCount = index
      this.tabs.splice(0, index)
      // 调整当前选中的索引
      if (this.current < removedCount) {
        this.current = 0
      } else {
        this.current -= removedCount
      }
      this.calculateTabWidth()
      this.showMessage(MessageType.INFO, '操作完成', `已关闭左侧 ${removedCount} 个页面`)
    }
  }

  private closeRightTabs(index: number): void {
    if (index < this.tabs.length - 1) {
      const removedCount = this.tabs.length - index - 1
      this.tabs.splice(index + 1)
      // 调整当前选中的索引
      if (this.current > index) {
        this.current = index
      }
      this.calculateTabWidth()
      this.showMessage(MessageType.INFO, '操作完成', `已关闭右侧 ${removedCount} 个页面`)
    }
  }

  private closeOtherTabs(index: number): void {
    if (this.tabs.length > 1) {
      const removedCount = this.tabs.length - 1
      const keepTab = this.tabs[index]
      this.tabs = [keepTab]
      this.current = 0
      this.calculateTabWidth()
      this.showMessage(MessageType.INFO, '操作完成', `已关闭其他 ${removedCount} 个页面`)
    }
  }

  // 获取主菜单回调函数
  private getMainMenuCallbacks(): MenuCallbacks {
    return {
      onNewFile: () => this.addNewTab(),
      onOpenFile: () => this.openFile(),
      onSaveFile: () => this.saveFile(),
      onSaveAsFile: () => this.saveAsFile(),
      onShowMessage: (type: MessageType, title: string, content: string) => this.showMessage(type, title, content),
      onExitApp: () => this.exitApp()
    }
  }

  // 获取Tab右键菜单回调函数
  private getTabMenuCallbacks(): TabMenuCallbacks {
    return {
      onCloseLeftTabs: (index: number) => this.closeLeftTabs(index),
      onCloseRightTabs: (index: number) => this.closeRightTabs(index),
      onCloseOtherTabs: (index: number) => this.closeOtherTabs(index)
    }
  }
  // 使用官方Button组件的菜单按钮
  @Builder
  buildMenuButton() {
    Button({ type: ButtonType.Normal }) {
      Column() {
        Row().width(14).height(2).backgroundColor($r('app.color.app_text_primary')).borderRadius(1)
        Row().width(14).height(2).backgroundColor($r('app.color.app_text_primary')).borderRadius(1).margin({ top: 3 })
        Row().width(14).height(2).backgroundColor($r('app.color.app_text_primary')).borderRadius(1).margin({ top: 3 })
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
    }
    .width(28)
    .height(28)
    .backgroundColor(Color.Transparent)
    .borderRadius(4)
    .padding(0)
    .stateStyles({
      normal: {
        .backgroundColor(Color.Transparent)
      },
      pressed: {
        .backgroundColor($r('app.color.button_pressed_bg'))
      },
      focused: {
        .backgroundColor($r('app.color.button_hover_bg'))
      }
    })
    .onClick(() => { this.showMenu = !this.showMenu })
    .padding({right:8})
  }

  // 使用官方Button组件的添加按钮
  @Builder
  buildAddButton() {
    Button({ type: ButtonType.Normal }) {
      Stack() {
        Row().width(10).height(2).backgroundColor($r('app.color.add_button_text')).borderRadius(1)
        Column().width(2).height(10).backgroundColor($r('app.color.add_button_text')).borderRadius(1)
      }
    }
    .width(32)
    .height(28)
    .backgroundColor($r('app.color.app_add_button_bg'))
    .borderRadius(4)
    .padding(0)
    .stateStyles({
      normal: {
        .backgroundColor($r('app.color.app_add_button_bg'))
      },
      pressed: {
        .backgroundColor($r('app.color.button_pressed_bg'))
      },
      focused: {
        .backgroundColor($r('app.color.button_hover_bg'))
      }
    })
    .onClick(() => {
      this.tabs.push(this.nextTitle())
      this.current = this.tabs.length - 1
      this.calculateTabWidth()
    })
  }

  // 使用官方Button组件的关闭按钮
  @Builder
  buildCloseButton(index: number) {
    Button({ type: ButtonType.Normal }) {
      Stack() {
        // 绘制X的两条线
        Row()
          .width(10)
          .height(1.5)
          .backgroundColor($r('app.color.tab_close_button'))
          .borderRadius(1)
          .rotate({ angle: 45 })
        Row()
          .width(10)
          .height(1.5)
          .backgroundColor($r('app.color.tab_close_button'))
          .borderRadius(1)
          .rotate({ angle: -45 })
      }
    }
    .width(18)
    .height(18)
    .backgroundColor(Color.Transparent)
    .borderRadius(3)
    .padding(0)
    .stateStyles({
      normal: {
        .backgroundColor(Color.Transparent)
      },
      pressed: {
        .backgroundColor($r('app.color.close_button_pressed_bg'))
      },
      focused: {
        .backgroundColor($r('app.color.close_button_hover_bg'))
      }
    })
    .onClick(() => {
      this.tabs.splice(index, 1)
      if (this.current >= this.tabs.length) this.current = this.tabs.length - 1
      this.calculateTabWidth()
    })
  }

  // 绘制单个Tab项 - 使用stateStyles优化hover效果
  @Builder
  buildTabItem(title: string, index: number) {
    Row({ space: 8 }) {
      Text(title)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(this.tabWidth - 40)
        .fontColor(this.current === index ?
        $r('app.color.tab_active_text') :
        $r('app.color.tab_inactive_text'))
        .fontSize(14)
      this.buildCloseButton(index)
    }
    .width(this.tabWidth)
    .height(28)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(this.current === index ?
    $r('app.color.app_tab_active_bg') :
    $r('app.color.app_tab_inactive_bg'))
    .borderRadius(4)
    .justifyContent(FlexAlign.SpaceBetween)
    .stateStyles({
      normal: {
        .backgroundColor(this.current === index ?
        $r('app.color.app_tab_active_bg') :
        $r('app.color.app_tab_inactive_bg'))
      },
      pressed: {
        .backgroundColor($r('app.color.tab_pressed_bg'))
      },
      focused: {
        .backgroundColor(this.current === index ?
        $r('app.color.app_tab_active_hover_bg') :
        $r('app.color.app_tab_inactive_hover_bg'))
      }
    })
    .onClick(() => { this.current = index })
    .onMouse((e: MouseEvent) => {
      if (e.button === MouseButton.Right && e.action === MouseAction.Press) {
        this.contextMenuTabIndex = index
        this.contextMenuPosition = { x: e.screenX, y: 48 }
        this.showTabContextMenu = true
      }
    })
    .gesture(LongPressGesture({ repeat: false })
      .onAction((event: GestureEvent) => {
        this.contextMenuTabIndex = index
        this.contextMenuPosition = { x: event.fingerList[0].globalX, y: 48 }
        this.showTabContextMenu = true
      }))
  }

  // 绘制Tab列表
  @Builder
  buildTabList() {
    ForEach(this.tabs, (title: string, idx: number) => {
      this.buildTabItem(title, idx)
    })
  }

  // 绘制Tabs容器
  @Builder
  buildTabsContainer() {
    if (this.needScroll) {
      // 滚动容器
      Scroll() {
        Row({ space: 4 }) {
          this.buildTabList()
          if (this.tabs.length > 0) Row().layoutWeight(1)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }
      .scrollable(ScrollDirection.Horizontal)
      .height(48)
      .layoutWeight(1)

      // 新建标签按钮
      this.buildAddButton()
    } else {
      // 非滚动容器
      Row({ space: 4 }) {
        this.buildTabList()
        this.buildAddButton()
        Row().layoutWeight(1)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
  }

  aboutToAppear() {
    this.calculateTabWidth()
  }

  build() {
    Stack() {
      Column() {
        /* ── 顶部栏 ── */
        Row() {
          /* 菜单按钮 */
          Row(){
            this.buildMenuButton()
          }.padding({right: 8})

          /* 左竖线 */
          Divider()
            .width(1)
            .height(18)
            .backgroundColor($r('app.color.app_border_light'))

          /* =========== Tabs 区域 =========== */
          Row() {
            this.buildTabsContainer()
          }
          .padding({ left: 12, right: 12 })
          .layoutWeight(1)
          .onAreaChange((_oldV: Area, newV: Area) => {
            this.containerWidth = Number(newV.width) - 24
            this.calculateTabWidth()
          })

          /* 右竖线 */
          Divider()
            .width(1)
            .height(18)
            .backgroundColor($r('app.color.app_border_light'))
        }
        .height(48)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 12, right: 140 })
        .width('100%')
        .backgroundColor($r('app.color.toolbar_bg'))

        /* ── 内容区 ── */
        Tabs({ index: this.current }) {
          ForEach(this.tabs, (title: string, idx: number) => {
            TabContent() {
              Column() {
                Text(`This is ${title}`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.app_text_title'))
                Text(`Tab index: ${idx}`)
                  .margin({ top: 8 })
                  .fontColor($r('app.color.app_text_secondary'))
                Text(`Current tab width: ${this.tabWidth}vp`)
                  .margin({ top: 8 })
                  .fontSize(14)
                  .fontColor($r('app.color.app_text_secondary'))
                Text(`Need scroll: ${this.needScroll ? 'Yes' : 'No'}`)
                  .margin({ top: 4 })
                  .fontSize(14)
                  .fontColor($r('app.color.app_text_secondary'))
                if (this.selectedFilePath) {
                  Text(`Selected file: ${this.selectedFilePath}`)
                    .margin({ top: 8 })
                    .fontSize(12)
                    .fontColor($r('app.color.app_text_secondary'))
                    .textAlign(TextAlign.Center)
                    .width('90%')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                Text('长按Tab标签可以显示右键菜单')
                  .margin({ top: 16 })
                  .fontSize(12)
                  .fontColor($r('app.color.app_text_tertiary'))
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .backgroundColor($r('app.color.app_content_bg'))
          })
        }
        .barHeight(0)
        .scrollable(false)
        .width('100%')
        .height('100%')
        .onChange((i: number) => { this.current = i })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.app_background'))

      /* ── 主菜单弹窗 ── */
      if (this.showMenu) {
        MenuComponent({
          menuData: getMainMenuData(this.getMainMenuCallbacks()),
          onMenuItemClick: (action?: () => void) => { if (action) action(); this.showMenu = false },
          onBackgroundClick: () => { this.showMenu = false }
        })
      }

      /* ── Tab右键菜单 ── */
      if (this.showTabContextMenu && this.contextMenuTabIndex >= 0) {
        TabContextMenuComponent({
          menuData: getTabContextMenuData(this.contextMenuTabIndex, this.getTabMenuCallbacks()),
          menuPosition: this.contextMenuPosition,
          onMenuItemClick: (action?: () => void) => { if (action) action(); this.showTabContextMenu = false; this.contextMenuTabIndex = -1 },
          onBackgroundClick: () => { this.showTabContextMenu = false; this.contextMenuTabIndex = -1 }
        })
      }

      /* ── 消息对话框 ── */
      if (this.showMessageDialog) {
        MessageDialogComponent({
          message: this.currentMessage,
          onConfirm: () => { this.showMessageDialog = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      if (this.showMenu) this.showMenu = false
      if (this.showTabContextMenu) { this.showTabContextMenu = false; this.contextMenuTabIndex = -1 }
    })
  }
}