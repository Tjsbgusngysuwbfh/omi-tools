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
| **batch-rename** | 批量文件重命名 | `.\batch-rename\batch-rename.ps1` |
| **disk-clean** | 磁盘空间清理 | `.\disk-clean\disk-clean.ps1` |

## 🚀 快速开始

```powershell
# 克隆仓库
git clone https://github.com/Tjsbgusngysuwbfh/omi-tools.git
cd omi-tools

# 运行任一工具
.\cliphist\cliphist.ps1
.\sys-health\sys-health.ps1
.\disk-clean\disk-clean.ps1 -DryRun
```

## 📋 工具详解

### cliphist - 剪贴板历史管理

比 Windows 自带的 Win+V 更强大：

```powershell
.\cliphist.ps1                    # 显示最近 20 条历史
.\cliphist.ps1 -Search "关键词"    # 搜索历史
.\cliphist.ps1 -Pin "常用内容"     # 固定常用内容
.\cliphist.ps1 -Watch             # 后台监控模式
.\cliphist.ps1 -Export            # 导出历史
```

### file-organizer - 智能文件分类

一键整理混乱的文件夹：

```powershell
.\file-organizer.ps1 -Path "C:\Downloads" -DryRun   # 预览
.\file-organizer.ps1 -Path "C:\Downloads" -Execute   # 执行
```

### batch-rename - 批量文件重命名

```powershell
.\batch-rename.ps1 -Path "C:\Photos" -Prefix "旅行_"      # 加前缀
.\batch-rename.ps1 -Path "C:\Photos" -Replace "IMG","照片" # 替换文字
.\batch-rename.ps1 -Path "C:\Photos" -Sequence -Start 1   # 序号命名
.\batch-rename.ps1 -Path "C:\Photos" -Date                 # 日期命名
```

### disk-clean - 磁盘空间清理

```powershell
.\disk-clean.ps1 -DryRun      # 预览可清理内容
.\disk-clean.ps1 -Execute     # 执行清理
.\disk-clean.ps1 -Deep        # 深度清理
```

### sys-health - 系统健康检查

```powershell
.\sys-health.ps1          # 完整检查
.\sys-health.ps1 -Quick   # 快速检查
```

### quick-menu - 右键菜单管理

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
