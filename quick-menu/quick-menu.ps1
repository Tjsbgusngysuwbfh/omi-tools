<#
.SYNOPSIS
    Windows 右键菜单快速管理工具
.DESCRIPTION
    添加/删除/查看 Windows 右键菜单项
.EXAMPLE
    .\quick-menu.ps1 -List
    .\quick-menu.ps1 -Add "用记事本打开" "notepad.exe `"%1`""
    .\quick-menu.ps1 -Remove "用记事本打开"
#>

param(
    [switch]$List,
    [string]$Add,
    [string]$Command,
    [string]$Remove,
    [switch]$Help
)

if($Help) {
    Write-Host @"
用法:
  .\quick-menu.ps1 -List                    # 列出所有自定义菜单
  .\quick-menu.ps1 -Add "名称" "命令"       # 添加菜单项
  .\quick-menu.ps1 -Remove "名称"           # 删除菜单项
  .\quick-menu.ps1 -Help                    # 显示帮助
"@ -ForegroundColor Cyan
    return
}

$regPath = "HKCU:\Software\Classes\*\shell\OmiTools"

if($List) {
    if(-not (Test-Path $regPath)) {
        Write-Host "还没有自定义菜单项" -ForegroundColor Yellow
        return
    }
    Get-ChildItem $regPath | ForEach-Object {
        $name = $_.PSChildName
        $cmd = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).Command
        Write-Host "📌 $name" -ForegroundColor Green
        Write-Host "   命令: $cmd" -ForegroundColor Gray
    }
}

if($Add -and $Command) {
    if(-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    $itemPath = "$regPath\$Add"
    New-Item -Path $itemPath -Force | Out-Null
    Set-ItemProperty -Path $itemPath -Name "Command" -Value $Command
    Write-Host "✅ 已添加: $Add" -ForegroundColor Green
}

if($Remove) {
    $itemPath = "$regPath\$Remove"
    if(Test-Path $itemPath) {
        Remove-Item $itemPath -Recurse -Force
        Write-Host "🗑️ 已删除: $Remove" -ForegroundColor Yellow
    } else {
        Write-Host "未找到: $Remove" -ForegroundColor Red
    }
}
