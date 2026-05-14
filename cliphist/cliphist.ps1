<#
.SYNOPSIS
    Windows 剪贴板历史管理工具
.DESCRIPTION
    自动记录剪贴板历史，支持搜索、粘贴历史、常用内容管理
    比 Windows 自带的 Win+V 更强大
.EXAMPLE
    .\cliphist.ps1                 # 显示剪贴板历史
    .\cliphist.ps1 -Search "关键词"  # 搜索历史
    .\cliphist.ps1 -Pin "常用内容"   # 固定常用内容
    .\cliphist.ps1 -Export          # 导出历史
    .\cliphist.ps1 -Watch           # 后台监控模式
#>

param(
    [switch]$List,
    [string]$Search,
    [string]$Pin,
    [string]$Paste,
    [switch]$Export,
    [switch]$Watch,
    [int]$Clear,
    [switch]$Help
)

$clipHistDir = "$env:USERPROFILE\.cliphist"
$clipHistFile = "$clipHistDir\history.json"
$clipPinsFile = "$clipHistDir\pins.json"

# Initialize
if(-not (Test-Path $clipHistDir)) { New-Item -ItemType Directory -Path $clipHistDir -Force | Out-Null }

function Get-ClipHistory {
    if(Test-Path $clipHistFile) {
        return Get-Content $clipHistFile -Raw | ConvertFrom-Json
    }
    return @()
}

function Save-ClipHistory {
    param($history)
    $history | ConvertTo-Json -Depth 10 | Set-Content $clipHistFile -Encoding UTF8
}

function Add-ClipEntry {
    param($text)
    if([string]::IsNullOrWhiteSpace($text)) { return }
    $history = @(Get-ClipHistory)
    
    # Skip duplicates (last entry)
    if($history.Count -gt 0 -and $history[0].text -eq $text) { return }
    
    $entry = @{
        text = $text.Substring(0, [Math]::Min(5000, $text.Length))
        time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        length = $text.Length
    }
    
    $history = @($entry) + $history
    if($history.Count -gt 500) { $history = $history[0..499] }
    Save-ClipHistory $history
}

function Get-ClipPins {
    if(Test-Path $clipPinsFile) {
        return Get-Content $clipPinsFile -Raw | ConvertFrom-Json
    }
    return @()
}

function Save-ClipPins {
    param($pins)
    $pins | ConvertTo-Json -Depth 10 | Set-Content $clipPinsFile -Encoding UTF8
}

# Help
if($Help) {
    Write-Host @"
📋 Omi 剪贴板历史管理工具

用法:
  .\cliphist.ps1                    # 显示最近 20 条历史
  .\cliphist.ps1 -List              # 列出所有历史
  .\cliphist.ps1 -Search "关键词"    # 搜索历史
  .\cliphist.ps1 -Pin "常用内容"     # 固定常用内容
  .\cliphist.ps1 -Paste 3           # 粘贴第 3 条
  .\cliphist.ps1 -Export            # 导出为文件
  .\cliphist.ps1 -Watch             # 后台监控（记录所有复制）
  .\cliphist.ps1 -Clear 100         # 清理旧记录（保留最近 100 条）
"@ -ForegroundColor Cyan
    return
}

# Watch mode - monitor clipboard
if($Watch) {
    Write-Host "🔍 开始监控剪贴板... (Ctrl+C 停止)" -ForegroundColor Green
    $lastText = ""
    while($true) {
        try {
            $currentText = Get-Clipboard -Format Text -ErrorAction SilentlyContinue
            if($currentText -and $currentText -ne $lastText) {
                Add-ClipEntry $currentText
                $preview = $currentText.Substring(0, [Math]::Min(60, $currentText.Length))
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 📋 $preview..." -ForegroundColor Gray
                $lastText = $currentText
            }
        } catch {}
        Start-Sleep -Milliseconds 500
    }
}

# Search
if($Search) {
    $history = @(Get-ClipHistory)
    $results = $history | Where-Object { $_.text -match [regex]::Escape($Search) }
    if($results.Count -eq 0) {
        Write-Host "未找到: $Search" -ForegroundColor Yellow
    } else {
        Write-Host "🔍 搜索结果 ($($results.Count) 条):" -ForegroundColor Cyan
        $i = 1
        foreach($r in $results) {
            $preview = $r.text.Substring(0, [Math]::Min(80, $r.length))
            Write-Host "  [$i] $($r.time) | $($r.length) 字符" -ForegroundColor Gray
            Write-Host "      $preview" -ForegroundColor White
            $i++
        }
    }
    return
}

# Pin
if($Pin) {
    $pins = @(Get-ClipPins)
    $pins = @(@{ text = $Pin; time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") }) + $pins
    Save-ClipPins $pins
    Write-Host "📌 已固定: $Pin" -ForegroundColor Green
    return
}

# Paste specific entry
if($Paste) {
    $history = @(Get-ClipHistory)
    if($Paste -le $history.Count) {
        $entry = $history[$Paste - 1]
        Set-Clipboard -Value $entry.text
        $preview = $entry.text.Substring(0, [Math]::Min(60, $entry.length))
        Write-Host "✅ 已复制到剪贴板: $preview..." -ForegroundColor Green
    } else {
        Write-Host "序号超出范围" -ForegroundColor Red
    }
    return
}

# Export
if($Export) {
    $history = @(Get-ClipHistory)
    $exportFile = "$clipHistDir\export_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $history | ForEach-Object { "[$($_.time)] $($_.text)" } | Set-Content $exportFile -Encoding UTF8
    Write-Host "📁 已导出到: $exportFile" -ForegroundColor Green
    return
}

# Clear old entries
if($Clear) {
    $history = @(Get-ClipHistory)
    if($history.Count -gt $Clear) {
        $history = $history[0..($Clear-1)]
        Save-ClipHistory $history
        Write-Host "🗑️ 已清理，保留最近 $Clear 条" -ForegroundColor Yellow
    }
    return
}

# Default: show recent history
$history = @(Get-ClipHistory)
$pins = @(Get-ClipPins)

# Show pins first
if($pins.Count -gt 0) {
    Write-Host "`n📌 常用内容:" -ForegroundColor Cyan
    $i = 1
    foreach($p in $pins) {
        $preview = $p.text.Substring(0, [Math]::Min(60, $p.text.Length))
        Write-Host "  [P$i] $preview" -ForegroundColor Yellow
        $i++
    }
}

# Show recent history
$showCount = [Math]::Min(20, $history.Count)
if($showCount -gt 0) {
    Write-Host "`n📋 最近 $showCount 条历史:" -ForegroundColor Cyan
    for($i = 0; $i -lt $showCount; $i++) {
        $entry = $history[$i]
        $preview = $entry.text.Substring(0, [Math]::Min(70, $entry.length))
        $num = $i + 1
        Write-Host "  [$num] " -ForegroundColor Gray -NoNewline
        Write-Host "$($entry.time) " -ForegroundColor DarkGray -NoNewline
        Write-Host "| $($entry.length) 字符" -ForegroundColor DarkGray
        Write-Host "      $preview" -ForegroundColor White
    }
} else {
    Write-Host "`n📋 剪贴板历史为空" -ForegroundColor Yellow
    Write-Host "  使用 -Watch 开始监控，或直接复制内容自动记录" -ForegroundColor Gray
}

Write-Host ""
