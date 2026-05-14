<#
.SYNOPSIS
    批量文件重命名工具
.DESCRIPTION
    支持前缀、后缀、替换、序号等多种重命名方式
.EXAMPLE
    .\batch-rename.ps1 -Path "C:\Photos" -Prefix "旅行_"
    .\batch-rename.ps1 -Path "C:\Photos" -Replace "IMG","照片"
    .\batch-rename.ps1 -Path "C:\Photos" -Sequence -Start 1
    .\batch-rename.ps1 -Path "C:\Photos" -Date
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [string]$Prefix,
    [string]$Suffix,
    [string]$Replace,
    [string]$With,
    [switch]$Sequence,
    [int]$Start = 1,
    [switch]$Date,
    [string]$Extension,
    [switch]$DryRun,
    [switch]$Help
)

if($Help) {
    Write-Host @"
📝 批量文件重命名工具

用法:
  .\batch-rename.ps1 -Path "文件夹" -Prefix "前缀_"         # 加前缀
  .\batch-rename.ps1 -Path "文件夹" -Suffix "_后缀"         # 加后缀
  .\batch-rename.ps1 -Path "文件夹" -Replace "旧","新"      # 替换文字
  .\batch-rename.ps1 -Path "文件夹" -Sequence -Start 1      # 序号命名
  .\batch-rename.ps1 -Path "文件夹" -Date                    # 日期命名
  .\batch-rename.ps1 -Path "文件夹" -Extension ".jpg"        # 只处理特定扩展名
  .\batch-rename.ps1 -Path "文件夹" -Prefix "img_" -DryRun  # 预览不执行
"@ -ForegroundColor Cyan
    return
}

if(-not (Test-Path $Path)) {
    Write-Host "路径不存在: $Path" -ForegroundColor Red
    return
}

$files = Get-ChildItem -Path $Path -File
if($Extension) {
    $files = $files | Where-Object { $_.Extension -eq $Extension }
}

if($files.Count -eq 0) {
    Write-Host "没有找到文件" -ForegroundColor Yellow
    return
}

Write-Host "📂 找到 $($files.Count) 个文件" -ForegroundColor Cyan
$counter = $Start
$renamed = 0

foreach($file in $files) {
    $newName = $file.BaseName
    
    if($Prefix) { $newName = "$Prefix$newName" }
    if($Suffix) { $newName = "$newName$Suffix" }
    if($Replace -and $With) { $newName = $newName.Replace($Replace, $With) }
    if($Sequence) { $newName = "$($counter.ToString('000'))_$newName"; $counter++ }
    if($Date) { $newName = "$($file.LastWriteTime.ToString('yyyyMMdd_HHmmss'))_$newName" }
    
    $newFullName = Join-Path $file.DirectoryName "$newName$($file.Extension)"
    
    if($DryRun) {
        Write-Host "  📎 $($file.Name) → $newName$($file.Extension)" -ForegroundColor Gray
    } else {
        Rename-Item -Path $file.FullName -NewName "$newName$($file.Extension)" -Force
        Write-Host "  ✅ $($file.Name) → $newName$($file.Extension)" -ForegroundColor Green
        $renamed++
    }
}

if($DryRun) {
    Write-Host "`n使用 -DryRun 预览，去掉后执行重命名" -ForegroundColor Yellow
} else {
    Write-Host "`n🎉 完成！重命名 $renamed 个文件" -ForegroundColor Green
}
