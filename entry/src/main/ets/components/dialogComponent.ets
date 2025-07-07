// 消息类型枚举
export enum MessageType {
  INFO = 'info',
  SUCCESS = 'success',
  WARNING = 'warning',
  ERROR = 'error'
}

// 消息接口
export interface Message {
  type: MessageType
  title: string
  content: string
}

const AnimationDuration: number = 200

@Component
export struct MessageDialogComponent {
  @Prop message: Message
  onConfirm: () => void = () => {}

  // 遮罩层和弹窗动画状态
  @State maskOpacity: number = 0
  @State dialogScale: number = 0.9
  @State dialogOpacity: number = 0

  aboutToAppear() {
    // 启动遮罩层和弹窗渐入动画
    setTimeout(() => {
      this.maskOpacity = 1
      this.dialogScale = 1
      this.dialogOpacity = 1
    }, 10)
  }

  // 处理遮罩层渐出
  private handleBackgroundClick() {
    // 先启动渐出动画
    this.maskOpacity = 0
    this.dialogScale = 0.9
    this.dialogOpacity = 0

    // 动画完成后调用回调
    setTimeout(() => {
      this.onConfirm()
    }, AnimationDuration)
  }

  private getIconColor(): ResourceColor {
    switch (this.message.type) {
      case MessageType.SUCCESS:  return $r('app.color.icon_success')
      case MessageType.ERROR:    return $r('app.color.icon_error')
      case MessageType.WARNING:  return $r('app.color.icon_warning')
      default:                   return $r('app.color.icon_info')
    }
  }

  private getIcon(): string {
    switch (this.message.type) {
      case MessageType.SUCCESS: return '✓'
      case MessageType.ERROR:   return '✗'
      case MessageType.WARNING: return '⚠'
      default:                  return 'ⓘ'
    }
  }

  build() {
    Stack() {
      /* 遮罩层 - 添加透明度控制 */
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.mask_light_10'))
        .opacity(this.maskOpacity) // 通过透明度控制渐入渐出
        .animation({
          duration: AnimationDuration,
          curve: Curve.EaseInOut
        })

      /* 弹窗内容 - 添加缩放和透明度动画 */
      Column() {
        /* 标题栏 */
        Row() {
          Text(this.getIcon())
            .fontSize(20)
            .fontColor(this.getIconColor())
            .width(24)
            .textAlign(TextAlign.Center)
          Text(this.message.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.dialog_title_text'))
            .layoutWeight(1)
            .margin({ left: 8 })
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16 })

        Divider()
          .width('100%')
          .height(1)
          .backgroundColor($r('app.color.dialog_divider'))

        /* 消息内容 */
        Column() {
          Text(this.message.content)
            .fontSize(14)
            .fontColor($r('app.color.dialog_content_text'))
            .textAlign(TextAlign.Start)
            .width('100%')
            .lineHeight(20)
            .maxLines(5)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .alignItems(HorizontalAlign.Start)

        /* 按钮区域 */
        Row() {
          Button('确定')
            .fontSize(14)
            .fontColor($r('app.color.dialog_button_text'))
            .backgroundColor(this.getIconColor())
            .borderRadius(4)
            .height(32)
            .width(80)
            .onClick(() => { this.handleBackgroundClick() })
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16 })
      }
      .width(320)
      .backgroundColor($r('app.color.dialog_bg'))
      .borderRadius(8)
      .shadow({
        radius: 12,
        color: $r('app.color.shadow_level2'),
        offsetX: 0,
        offsetY: 6
      })
      .scale({ x: this.dialogScale, y: this.dialogScale })
      .opacity(this.dialogOpacity)
      .animation({
        duration: AnimationDuration,
        curve: Curve.EaseInOut
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .align(Alignment.Center)
  }
}