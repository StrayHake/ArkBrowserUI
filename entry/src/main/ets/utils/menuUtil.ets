import {MenuItem} from '../components/menuComponent'
import {MessageType} from '../components/dialogComponent'

// 菜单配置接口
export interface  MenuCallbacks {
  onNewFile: () => void
  onOpenFile: () => void
  onSaveFile: () => void
  onSaveAsFile: () => void
  onShowMessage: (type: MessageType, title: string, content: string) => void
  onExitApp: () => void
}

export interface TabMenuCallbacks {
  onCloseLeftTabs: (index: number) => void
  onCloseRightTabs: (index: number) => void
  onCloseOtherTabs: (index: number) => void
}

// 获取主菜单配置数据
export function getMainMenuData(callbacks: MenuCallbacks): MenuItem[] {
  return [
    {
      title: '文件',
      children: [
        {
          title: '新建',
          action: callbacks.onNewFile
        },
        {
          title: '打开',
          action: callbacks.onOpenFile
        },
        {
          title: '保存',
          action: callbacks.onSaveFile
        },
        {
          title: '另存为',
          action: callbacks.onSaveAsFile
        },
        {
          title: '首选项',
          action: () => {
            callbacks.onShowMessage(MessageType.INFO, '首选项', '打开首选项设置')
          }
        },
        {
          title: '最近文件',
          children: [
            {
              title: 'document1.txt',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '打开文件', '已打开 document1.txt')
              }
            },
            {
              title: 'project.json',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '打开文件', '已打开 project.json')
              }
            },
            {
              title: 'readme.md',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '打开文件', '已打开 readme.md')
              }
            }
          ]
        }
      ]
    },
    {
      title: '编辑',
      children: [
        {
          title: '撤销',
          action: () => {
            callbacks.onShowMessage(MessageType.INFO, '撤销', '执行撤销操作')
          }
        },
        {
          title: '重做',
          action: () => {
            callbacks.onShowMessage(MessageType.INFO, '重做', '执行重做操作')
          }
        },
        {
          title: '复制',
          action: () => {
            callbacks.onShowMessage(MessageType.SUCCESS, '复制成功', '已复制选中内容')
          }
        },
        {
          title: '粘贴',
          action: () => {
            callbacks.onShowMessage(MessageType.SUCCESS, '粘贴成功', '已粘贴内容')
          }
        },
        {
          title: '查找替换',
          children: [
            {
              title: '查找',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '查找', '打开查找对话框')
              }
            },
            {
              title: '替换',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '替换', '打开替换对话框')
              }
            },
            {
              title: '在文件中查找',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '查找', '在文件中查找')
              }
            }
          ]
        }
      ]
    },
    {
      title: '帮助',
      children: [
        {
          title: '用户手册',
          action: () => {
            callbacks.onShowMessage(MessageType.INFO, '用户手册', '打开用户手册')
          }
        },
        {
          title: '快捷键',
          action: () => {
            callbacks.onShowMessage(MessageType.INFO, '快捷键', '显示快捷键列表')
          }
        },
        {
          title: '关于',
          action: () => {
            callbacks.onShowMessage(MessageType.INFO, '关于', '关于此应用 v1.0.0')
          }
        },
        {
          title: '检查更新',
          action: () => {
            callbacks.onShowMessage(MessageType.INFO, '检查更新', '检查更新中...')
          }
        },
        {
          title: '反馈',
          children: [
            {
              title: '报告bug',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '反馈', '打开bug报告页面')
              }
            },
            {
              title: '功能建议',
              action: () => {
                callbacks.onShowMessage(MessageType.INFO, '反馈', '打开功能建议页面')
              }
            }
          ]
        }
      ]
    },
    {
      title: '退出',
      action: callbacks.onExitApp
    }
  ]
}

// 获取Tab右键菜单配置数据
export function getTabContextMenuData(index: number, callbacks: TabMenuCallbacks): MenuItem[] {
  return [
    {
      title: '关闭左边页面',
      action: () => {
        callbacks.onCloseLeftTabs(index)
      }
    },
    {
      title: '关闭右边页面',
      action: () => {
        callbacks.onCloseRightTabs(index)
      }
    },
    {
      title: '关闭其他页面',
      action: () => {
        callbacks.onCloseOtherTabs(index)
      }
    }
  ]
}