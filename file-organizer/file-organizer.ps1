<#
.SYNOPSIS
    智能文件分类整理工具
.DESCRIPTION
    根据文件类型自动分类到对应文件夹
.EXAMPLE
    .\file-organizer.ps1 -Path "C:\Downloads" -DryRun
    .\file-organizer.ps1 -Path "C:\Downloads" -Execute
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [switch]$DryRun,
    [switch]$Execute,
    [switch]$Help
)

if($Help) {
    Write-Host @"
用法:
  .\file-organizer.ps1 -Path "文件夹路径" -DryRun   # 预览分类结果
  .\file-organizer.ps1 -Path "文件夹路径" -Execute   # 执行分类
"@ -ForegroundColor Cyan
    return
}

$categories = @{
    "图片"     = @(".jpg",".jpeg",".png",".gif",".bmp",".webp",".svg",".ico")
    "视频"     = @(".mp4",".avi",".mkv",".mov",".wmv",".flv",".webm")
    "音乐"     = @(".mp3",".wav",".flac",".aac",".ogg",".wma")
    "文档"     = @(".pdf",".doc",".docx",".xls",".xlsx",".ppt",".pptx",".txt",".md")
    "压缩包"   = @(".zip",".rar",".7z",".tar",".gz",".bz2")
    "代码"     = @(".py",".js",".ts",".java",".c",".cpp",".h",".go",".rs",".ps1",".bat",".sh")
    "安装包"   = @(".exe",".msi",".dmg",".apk")
    "字体"     = @(".ttf",".otf",".woff",".woff2")
}

if(-not (Test-Path $Path)) {
    Write-Host "路径不存在: $Path" -ForegroundColor Red
    return
}

$files = Get-ChildItem -Path $Path -File
$moved = 0

foreach($file in $files) {
    $ext = $file.Extension.ToLower()
    $targetCategory = "其他"
    
    foreach($cat in $categories.GetEnumerator()) {
        if($cat.Value -contains $ext) {
            $targetCategory = $cat.Key
            break
        }
    }
    
    $targetDir = Join-Path $Path $targetCategory
    
    if($DryRun) {
        Write-Host "📎 $($file.Name) → $targetCategory/" -ForegroundColor Gray
    }
    
    if($Execute) {
        if(-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        Move-Item -Path $file.FullName -Destination $targetDir -Force
        Write-Host "✅ $($file.Name) → $targetCategory/" -ForegroundColor Green
        $moved++
    }
}

if($DryRun) {
    Write-Host "`n共 $($files.Count) 个文件，使用 -Execute 执行分类" -ForegroundColor Yellow
}

if($Execute) {
    Write-Host "`n🎉 完成！共移动 $moved 个文件" -ForegroundColor Green
}
