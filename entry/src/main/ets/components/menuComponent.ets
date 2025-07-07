// 菜单项接口
export interface MenuItem {
  title: string
  action?: () => void
  children?: MenuItem[]
}

// 位置接口
export interface MenuPosition {
  x: number
  y: number
}

const AnimationDuration: number = 200

@Component
export struct MenuComponent {
  @Prop menuData: MenuItem[]
  onMenuItemClick: (action?: () => void) => void = () => {}
  onBackgroundClick: () => void = () => {}

  // 使用路径字符串来跟踪展开状态
  @State expandedPaths: Set<string> = new Set()

  // 遮罩层和菜单动画状态
  @State maskOpacity: number = 0
  @State menuScale: number = 0.9
  @State menuOpacity: number = 0
  @State menuHeight: number = 0

  aboutToAppear() {
    // 计算菜单的初始高度（只包含顶层菜单项）
    const initialHeight: number = this.calculateInitialMenuHeight()

    // 启动遮罩层和菜单渐入动画
    setTimeout(() => {
      this.maskOpacity = 1
      this.menuScale = 1
      this.menuOpacity = 1
      this.menuHeight = initialHeight
    }, 10)
  }

  // 处理遮罩层渐出
  private handleBackgroundClick() {
    // 先启动渐出动画
    this.maskOpacity = 0
    this.menuScale = 0.9
    this.menuOpacity = 0
    this.menuHeight = 0

    // 动画完成后调用回调
    setTimeout(() => {
      this.onBackgroundClick()
    }, 150)
  }

  build() {
    Column() {
      /* 遮罩层 - 添加透明度控制 */
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.mask_light_10'))
        .opacity(this.maskOpacity) // 通过透明度控制渐入渐出
        .onClick(() => { this.handleBackgroundClick() })
        .animation({
          duration: AnimationDuration,
          curve: Curve.EaseInOut
        })

      /* 菜单内容 - 添加高度、缩放和透明度动画 */
      Column() {
        ForEach(this.menuData, (item: MenuItem, index: number) => {
          this.buildMenuItem(item, index.toString(), 0)
        })
      }
      .width(200)
      .backgroundColor($r('app.color.menu_bg'))
      .borderRadius(8)
      .shadow({
        radius: 8,
        color: $r('app.color.shadow_level1'),
        offsetX: 0,
        offsetY: 4
      })
      .padding(4)
      .position({ x: 12, y: 48 })
      .clip(true)
      .height(this.menuHeight) // 动态高度
      .scale({ x: this.menuScale, y: this.menuScale })
      .opacity(this.menuOpacity)
      .animation({
        duration: AnimationDuration,
        curve: Curve.EaseInOut
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  buildMenuItem(item: MenuItem, path: string, level: number) {
    Column() {
      // 主菜单项
      Row() {
        Text(item.title)
          .fontSize(14)
          .fontColor($r('app.color.menu_text'))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        // 如果有子菜单，显示可旋转的三角形
        if (item.children && item.children.length > 0) {
          Text('▶')
            .fontSize(12)
            .fontColor($r('app.color.menu_arrow'))
            .backgroundColor(Color.Transparent)
            .rotate({
              angle: this.expandedPaths.has(path) ? 90 : 0,
              centerX: '50%',
              centerY: '50%'
            })
            .animation({
              duration: AnimationDuration,
              curve: Curve.EaseInOut
            })
        }
      }
      .width('100%')
      .height(32)
      .padding({ left: 8 + level * 16, right: 8 })
      .backgroundColor(this.expandedPaths.has(path) ? $r('app.color.menu_expanded_bg') : Color.Transparent)
      .borderRadius(4)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (item.children && item.children.length > 0) {
          this.handleMenuToggle(path)
        } else {
          this.onMenuItemClick(item.action)
        }
      })

      // 子菜单容器
      if (item.children && item.children.length > 0) {
        Column() {
          ForEach(item.children, (child: MenuItem, childIndex: number) => {
            this.buildMenuItem(child, path + '-' + childIndex.toString(), level + 1)
          })
        }
        .width('100%')
        .backgroundColor($r('app.color.menu_children_bg'))
        .borderRadius(4)
        .padding({ top: 2, bottom: 2 })
        .clip(true)
        .height(this.expandedPaths.has(path) ?
        this.calculateMenuHeight(item.children, path) : 0)
        .animation({
          duration: AnimationDuration,
          curve: Curve.EaseInOut
        })
      }
    }
    .margin({ bottom: level === 0 ? 1 : 0 })
  }

  // 计算菜单的初始高度（只包含顶层菜单项）
  private calculateInitialMenuHeight(): number {
    const itemHeight: number = 32
    const padding: number = 8 // 上下各4px
    const marginBottom: number = this.menuData.length > 1 ? (this.menuData.length - 1) * 1 : 0
    const totalHeight: number = this.menuData.length * itemHeight + padding + marginBottom
    return totalHeight
  }

  private calculateMenuHeight(children: MenuItem[], parentPath: string): number {
    let height: number = 0

    for (let i = 0; i < children.length; i++) {
      height += 32

      const childPath: string = parentPath + '-' + i.toString()
      const child: MenuItem = children[i]

      if (child.children &&
        child.children.length > 0 &&
      this.expandedPaths.has(childPath)) {
        height += this.calculateMenuHeight(child.children, childPath)
      }
    }

    height += 4
    return height
  }

  private handleMenuToggle(path: string) {
    const isExpanded: boolean = this.expandedPaths.has(path)

    if (isExpanded) {
      this.collapseMenuAndChildren(path)
    } else {
      this.closeSiblingMenus(path)
      this.expandedPaths.add(path)
    }

    // 当子菜单展开/收起时，需要重新计算并更新整个菜单的高度
    setTimeout(() => {
      this.updateMenuHeight()
    }, 10)
  }

  // 更新菜单总高度
  private updateMenuHeight() {
    let totalHeight: number = this.calculateInitialMenuHeight()

    // 只遍历顶层菜单项，calculateMenuHeight会自动递归处理所有展开的子菜单
    for (let i = 0; i < this.menuData.length; i++) {
      const topLevelPath: string = i.toString()
      if (this.expandedPaths.has(topLevelPath)) {
        const menuItem: MenuItem = this.menuData[i]
        if (menuItem.children && menuItem.children.length > 0) {
          totalHeight += this.calculateMenuHeight(menuItem.children, topLevelPath)
        }
      }
    }

    this.menuHeight = totalHeight
  }

  private collapseMenuAndChildren(path: string) {
    const pathsToDelete: string[] = []
    const targetPrefix: string = path + '-'

    this.expandedPaths.forEach((expandedPath: string) => {
      if (expandedPath === path || expandedPath.indexOf(targetPrefix) === 0) {
        pathsToDelete.push(expandedPath)
      }
    })

    for (let i = 0; i < pathsToDelete.length; i++) {
      this.expandedPaths.delete(pathsToDelete[i])
    }
  }

  private closeSiblingMenus(currentPath: string) {
    const pathsToDelete: string[] = []
    const currentLevel: number = this.getPathLevel(currentPath)
    const currentParent: string = this.getParentPath(currentPath)

    this.expandedPaths.forEach((expandedPath: string) => {
      const expandedLevel: number = this.getPathLevel(expandedPath)
      const expandedParent: string = this.getParentPath(expandedPath)

      if (expandedLevel === currentLevel &&
        expandedParent === currentParent &&
        expandedPath !== currentPath) {
        pathsToDelete.push(expandedPath)

        const childPrefix: string = expandedPath + '-'
        this.expandedPaths.forEach((subPath: string) => {
          if (subPath.indexOf(childPrefix) === 0) {
            pathsToDelete.push(subPath)
          }
        })
      }
    })

    const uniquePaths: Set<string> = new Set(pathsToDelete)
    uniquePaths.forEach((pathToDelete: string) => {
      this.expandedPaths.delete(pathToDelete)
    })
  }

  private getPathLevel(path: string): number {
    let level: number = 0
    for (let i = 0; i < path.length; i++) {
      if (path.charAt(i) === '-') {
        level++
      }
    }
    return level
  }

  private getParentPath(path: string): string {
    const lastDashIndex: number = path.lastIndexOf('-')
    if (lastDashIndex === -1) {
      return ''
    }
    return path.substring(0, lastDashIndex)
  }
}

@Component
export struct TabContextMenuComponent {
  @Prop menuData: MenuItem[]
  @Prop menuPosition: MenuPosition
  onMenuItemClick: (action?: () => void) => void = () => {}
  onBackgroundClick: () => void = () => {}

  // 遮罩层和菜单动画状态
  @State maskOpacity: number = 0
  @State menuOpacity: number = 0
  @State menuHeight: number = 0
  @State menuScale: number = 0.9

  aboutToAppear() {
    // 计算菜单的实际高度
    const actualHeight: number = this.calculateMenuHeight()

    // 启动渐入动画
    setTimeout(() => {
      this.maskOpacity = 1
      this.menuHeight = actualHeight
      this.menuOpacity = 1
      this.menuScale = 1
    }, 10)
  }

  // 处理遮罩层渐出
  private handleBackgroundClick() {
    // 启动渐出动画
    this.maskOpacity = 0
    this.menuHeight = 0
    this.menuScale = 0.9

    // 动画完成后调用回调
    setTimeout(() => {
      this.onBackgroundClick()
    }, 150)
  }

  build() {
    Column() {
      /* 遮罩层 - 添加透明度控制 */
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.mask_light_10'))
        .opacity(this.maskOpacity) // 通过透明度控制渐入渐出
        .onClick(() => { this.handleBackgroundClick() })
        .animation({
          duration: AnimationDuration,
          curve: Curve.EaseInOut
        })

      /* 菜单内容 - 添加完整的动画效果 */
      Column() {
        ForEach(this.menuData, (item: MenuItem) => {
          Row() {
            Text(item.title)
              .fontSize(14)
              .fontColor($r('app.color.context_menu_text'))
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .height(32)
          .padding({ left: 8, right: 8 })
          .backgroundColor(Color.Transparent)
          .borderRadius(4)
          .alignItems(VerticalAlign.Center)
          .stateStyles({
            pressed: {
              .backgroundColor($r('app.color.context_menu_pressed_bg'))
            }
          })
          .onClick(() => { this.onMenuItemClick(item.action) })
        })
      }
      .width(160)
      .backgroundColor($r('app.color.context_menu_bg'))
      .borderRadius(8)
      .shadow({
        radius: 8,
        color: $r('app.color.shadow_level1'),
        offsetX: 0,
        offsetY: 4
      })
      .padding(4)
      .position({ x: this.menuPosition.x, y: this.menuPosition.y })
      .clip(true)
      .height(this.menuHeight) // 动态高度
      .opacity(this.menuOpacity) // 动态透明度
      .scale({ x: this.menuScale, y: this.menuScale }) // 动态缩放
      .animation({
        duration: AnimationDuration,
        curve: Curve.EaseInOut
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  // 计算菜单的实际高度
  private calculateMenuHeight(): number {
    const itemHeight: number = 32
    const padding: number = 8
    const totalHeight: number = this.menuData.length * itemHeight + padding
    return totalHeight
  }
}