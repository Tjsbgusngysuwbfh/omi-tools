<#
.SYNOPSIS
    磁盘空间清理工具
.DESCRIPTION
    一键清理系统垃圾、临时文件、浏览器缓存等
.EXAMPLE
    .\disk-clean.ps1 -DryRun      # 预览可清理内容
    .\disk-clean.ps1 -Execute     # 执行清理
    .\disk-clean.ps1 -Deep        # 深度清理
#>

param(
    [switch]$DryRun,
    [switch]$Execute,
    [switch]$Deep,
    [switch]$Help
)

if($Help) {
    Write-Host @"
🧹 磁盘空间清理工具

用法:
  .\disk-clean.ps1 -DryRun      # 预览可清理内容
  .\disk-clean.ps1 -Execute     # 执行清理
  .\disk-clean.ps1 -Deep        # 深度清理（包括 Windows 更新缓存等）
"@ -ForegroundColor Cyan
    return
}

$cleanPaths = @(
    @{ Path = "$env:TEMP"; Name = "用户临时文件" },
    @{ Path = "C:\Windows\Temp"; Name = "系统临时文件" },
    @{ Path = "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"; Name = "IE/Edge 缓存" },
    @{ Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"; Name = "Chrome 缓存" },
    @{ Path = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"; Name = "缩略图缓存" },
    @{ Path = "$env:LOCALAPPDATA\CrashDumps"; Name = "崩溃转储" },
    @{ Path = "$env:LOCALAPPDATA\Temp"; Name = "本地临时文件" }
)

if($Deep) {
    $cleanPaths += @(
        @{ Path = "C:\Windows\SoftwareDistribution\Download"; Name = "Windows 更新缓存" },
        @{ Path = "C:\Windows\Installer\$PatchCache$"; Name = "安装补丁缓存" },
        @{ Path = "$env:LOCALAPPDATA\Microsoft\Windows\WER"; Name = "Windows 错误报告" }
    )
}

$totalSize = 0
$cleanedSize = 0

Write-Host "`n🧹 Omi 磁盘清理工具" -ForegroundColor Cyan
Write-Host "=" * 50

foreach($item in $cleanPaths) {
    if(Test-Path $item.Path) {
        $size = (Get-ChildItem -Path $item.Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        $totalSize += $size
        
        if($sizeMB -gt 0.1) {
            if($DryRun) {
                Write-Host "  📁 $($item.Name): ${sizeMB} MB" -ForegroundColor Gray
            }
            
            if($Execute) {
                Remove-Item -Path "$($item.Path)\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  ✅ $($item.Name): 清理 ${sizeMB} MB" -ForegroundColor Green
                $cleanedSize += $size
            }
        }
    }
}

$totalMB = [math]::Round($totalSize / 1MB, 2)
$cleanedMB = [math]::Round($cleanedSize / 1MB, 2)

Write-Host "`n" + "=" * 50 -ForegroundColor Cyan

if($DryRun) {
    Write-Host "可清理空间: ${totalMB} MB" -ForegroundColor Yellow
    Write-Host "使用 -Execute 执行清理" -ForegroundColor Gray
}

if($Execute) {
    Write-Host "🎉 清理完成！释放 ${cleanedMB} MB 空间" -ForegroundColor Green
}

# Show disk info
Write-Host "`n💾 磁盘状态:" -ForegroundColor White
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
    $totalGB = [math]::Round($_.Size / 1GB, 2)
    $percent = [math]::Round(($freeGB / $totalGB) * 100, 1)
    $color = if($percent -lt 20) { "Red" } elseif($percent -lt 40) { "Yellow" } else { "Green" }
    Write-Host "  $($_.DeviceID) 剩余 $freeGB GB / $totalGB GB ($percent%)" -ForegroundColor $color
}
