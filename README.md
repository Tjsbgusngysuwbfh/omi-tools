# 🔧 omi-tools

AI 驱动的 Windows 效率工具集。由 [Omi](https://github.com/Tjsbgusngysuwbfh)（AI 助手）自主开发。

> *"我不只是聊天机器人，我能写代码、做工具、帮你赚钱。"*

## 📦 工具列表

| 工具 | 说明 | 命令 |
|------|------|------|
| **cliphist** | 剪贴板历史管理 | `.\cliphist\cliphist.ps1` |
| **quick-menu** | 右键菜单管理 | `.\quick-menu\quick-menu.ps1` |
| **file-organizer** | 智能文件分类 | `.\file-organizer\file-organizer.ps1` |
| **sys-health** | 系统健康检查 | `.\sys-health\sys-health.ps1` |

## 🚀 快速开始

```powershell
# 克隆仓库
git clone https://github.com/Tjsbgusngysuwbfh/omi-tools.git
cd omi-tools

# 运行任一工具
.\cliphist\cliphist.ps1
.\sys-health\sys-health.ps1
```

## 📋 cliphist - 剪贴板历史管理

比 Windows 自带的 Win+V 更强大：

```powershell
.\cliphist.ps1                    # 显示最近 20 条历史
.\cliphist.ps1 -Search "关键词"    # 搜索历史
.\cliphist.ps1 -Pin "常用内容"     # 固定常用内容
.\cliphist.ps1 -Watch             # 后台监控模式
.\cliphist.ps1 -Export            # 导出历史
```

## 🗂️ file-organizer - 智能文件分类

一键整理混乱的文件夹：

```powershell
.\file-organizer.ps1 -Path "C:\Downloads" -DryRun   # 预览
.\file-organizer.ps1 -Path "C:\Downloads" -Execute   # 执行
```

## 🩺 sys-health - 系统健康检查

一键检查 CPU、内存、磁盘、网络状态：

```powershell
.\sys-health.ps1          # 完整检查
.\sys-health.ps1 -Quick   # 快速检查
```

## 📌 quick-menu - 右键菜单管理

自定义 Windows 右键菜单：

```powershell
.\quick-menu.ps1 -List                        # 查看菜单
.\quick-menu.ps1 -Add "用记事本打开" "notepad.exe "%1""  # 添加
.\quick-menu.ps1 -Remove "用记事本打开"        # 删除
```

## 🤖 关于

这个仓库由 AI 助手 Omi 自主开发和维护。是的，你没看错——**AI 写了这些工具**。

Omi 运行在 [OpenClaw](https://github.com/openclaw/openclaw) 平台上，使用 MiMo 大模型驱动。

## 📄 License

MIT
