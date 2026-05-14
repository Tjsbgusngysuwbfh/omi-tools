<#
.SYNOPSIS
    系统健康检查工具
.DESCRIPTION
    一键检查系统状态：磁盘、内存、CPU、网络、服务等
.EXAMPLE
    .\sys-health.ps1
    .\sys-health.ps1 -Quick
#>

param(
    [switch]$Quick,
    [switch]$Help
)

if($Help) {
    Write-Host @"
用法:
  .\sys-health.ps1          # 完整检查
  .\sys-health.ps1 -Quick   # 快速检查
"@ -ForegroundColor Cyan
    return
}

Write-Host "`n🔍 Omi 系统健康检查" -ForegroundColor Cyan
Write-Host "=" * 50

# CPU
$cpu = (Get-CimInstance Win32_Processor).LoadPercentage
$cpuColor = if($cpu -gt 80) { "Red" } elseif($cpu -gt 50) { "Yellow" } else { "Green" }
Write-Host "`n💻 CPU 使用率: $cpu%" -ForegroundColor $cpuColor

# 内存
$mem = Get-CimInstance Win32_OperatingSystem
$totalMem = [math]::Round($mem.TotalVisibleMemorySize/1MB, 2)
$freeMem = [math]::Round($mem.FreePhysicalMemory/1MB, 2)
$usedMem = $totalMem - $freeMem
$memPercent = [math]::Round(($usedMem/$totalMem)*100, 1)
$memColor = if($memPercent -gt 85) { "Red" } elseif($memPercent -gt 60) { "Yellow" } else { "Green" }
Write-Host "🧠 内存: $usedMem GB / $totalMem GB ($memPercent%)" -ForegroundColor $memColor

# 磁盘
Write-Host "`n💾 磁盘状态:" -ForegroundColor White
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $used = [math]::Round(($_.Size - $_.FreeSpace)/1GB, 1)
    $total = [math]::Round($_.Size/1GB, 1)
    $percent = [math]::Round((($used/$total)*100), 1)
    $dColor = if($percent -gt 90) { "Red" } elseif($percent -gt 70) { "Yellow" } else { "Green" }
    Write-Host "  $($_.DeviceID) $used GB / $total GB ($percent%)" -ForegroundColor $dColor
}

if(-not $Quick) {
    # 网络
    Write-Host "`n🌐 网络测试:" -ForegroundColor White
    $ping = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet
    if($ping) { Write-Host "  ✅ 网络连接正常" -ForegroundColor Green } 
    else { Write-Host "  ❌ 网络连接异常" -ForegroundColor Red }

    # 进程 TOP 5
    Write-Host "`n📊 CPU 占用 TOP 5:" -ForegroundColor White
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.ProcessName): $([math]::Round($_.CPU, 1))s" -ForegroundColor Gray
    }

    # 启动项
    Write-Host "`n🚀 启动项数量: $((Get-CimInstance Win32_StartupCommand).Count)" -ForegroundColor White
}

Write-Host "`n" + "=" * 50 -ForegroundColor Cyan
Write-Host "✅ 检查完成" -ForegroundColor Green
