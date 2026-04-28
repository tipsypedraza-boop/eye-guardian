#!/usr/bin/env pwsh
<#
.SYNOPSIS
    护眼精灵 - Windows 打包脚本
    直接使用 Windows 现有依赖打包

.DESCRIPTION
    自动化构建 Windows MSI 安装包的脚本

.EXAMPLE
    .\build-windows.ps1
#>

param(
    [switch]$SkipRustCheck = $false,
    [switch]$SkipIconGeneration = $false
)

# 颜色定义
$colors = @{
    Success = 'Green'
    Error   = 'Red'
    Warning = 'Yellow'
    Info    = 'Cyan'
}

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Success', 'Error', 'Warning', 'Info')]
        [string]$Type = 'Info'
    )
    
    $prefix = switch ($Type) {
        'Success' { '[✓]' }
        'Error'   { '[✗]' }
        'Warning' { '[!]' }
        'Info'    { '[*]' }
    }
    
    Write-Host "$prefix $Message" -ForegroundColor $colors[$Type]
}

function Test-Command {
    param([string]$Command)
    
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# 主程序
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "护眼精灵 - Windows 打包脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Node.js
Write-Status "检查 Node.js..." -Type Info
if (Test-Command node) {
    $nodeVersion = node --version
    Write-Status "Node.js $nodeVersion" -Type Success
}
else {
    Write-Status "未找到 Node.js" -Type Error
    Write-Host "请先安装 Node.js: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# 检查 npm
Write-Status "检查 npm..." -Type Info
if (Test-Command npm) {
    $npmVersion = npm --version
    Write-Status "npm $npmVersion" -Type Success
}
else {
    Write-Status "未找到 npm" -Type Error
    exit 1
}

# 检查 Rust
Write-Status "检查 Rust..." -Type Info
if (-not $SkipRustCheck) {
    if (Test-Command cargo) {
        $cargoVersion = cargo --version
        Write-Status $cargoVersion -Type Success
    }
    else {
        Write-Status "未找到 Rust" -Type Warning
        Write-Host ""
        Write-Host "需要安装 Rust 来构建 Tauri 应用" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "选择安装方式:" -ForegroundColor Yellow
        Write-Host "  1. 自动下载并安装 Rust" -ForegroundColor White
        Write-Host "  2. 手动安装（访问 https://rustup.rs/）" -ForegroundColor White
        Write-Host "  3. 取消" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "请输入选择 (1-3)"
        
        switch ($choice) {
            "1" {
                Write-Status "下载 Rust 安装程序..." -Type Info
                $rustUrl = "https://win.rustup.rs/x86_64"
                $rustInstaller = "$env:TEMP\rustup-init.exe"
                
                try {
                    Invoke-WebRequest -Uri $rustUrl -OutFile $rustInstaller -ErrorAction Stop
                    Write-Status "运行 Rust 安装程序..." -Type Info
                    & $rustInstaller -y
                    Remove-Item $rustInstaller -Force
                    Write-Status "Rust 安装完成" -Type Success
                    
                    # 刷新环境变量
                    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
                    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
                    $env:Path = "$machinePath;$userPath"
                }
                catch {
                    Write-Status "Rust 安装失败: $_" -Type Error
                    exit 1
                }
            }
            "2" {
                Write-Status "请访问 https://rustup.rs/ 安装 Rust" -Type Warning
                Write-Status "安装完成后，请重新运行此脚本" -Type Info
                exit 1
            }
            default {
                Write-Status "用户取消" -Type Warning
                exit 1
            }
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "环境检查完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 创建图标
if (-not $SkipIconGeneration) {
    Write-Status "步骤 1/5: 创建应用图标..." -Type Info
    try {
        python create-placeholder-icons.py
        Write-Status "图标准备完成" -Type Success
    }
    catch {
        Write-Status "图标生成失败，继续使用默认图标" -Type Warning
    }
    Write-Host ""
}

# 安装前端依赖
Write-Status "步骤 2/5: 安装前端依赖..." -Type Info
try {
    npm install
    Write-Status "前端依赖安装完成" -Type Success
}
catch {
    Write-Status "npm install 失败" -Type Error
    exit 1
}
Write-Host ""

# 构建前端
Write-Status "步骤 3/5: 构建前端资源..." -Type Info
try {
    npm run build
    Write-Status "前端资源构建完成" -Type Success
}
catch {
    Write-Status "前端构建失败" -Type Error
    exit 1
}
Write-Host ""

# 安装 Tauri CLI
Write-Status "步骤 4/5: 安装 Tauri CLI..." -Type Info
try {
    cargo install tauri-cli
    Write-Status "Tauri CLI 安装完成" -Type Success
}
catch {
    Write-Status "Tauri CLI 安装失败" -Type Error
    exit 1
}
Write-Host ""

# 构建应用
Write-Status "步骤 5/5: 构建 Windows MSI 包..." -Type Info
try {
    Push-Location src-tauri
    cargo tauri build --target x86_64-pc-windows-msvc
    Pop-Location
    Write-Status "构建完成" -Type Success
}
catch {
    Write-Status "构建失败" -Type Error
    Pop-Location
    exit 1
}
Write-Host ""

# 显示结果
Write-Host "========================================" -ForegroundColor Green
Write-Host "构建完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$msiPath = "src-tauri\target\x86_64-pc-windows-msvc\release\bundle\msi\"
$msiFile = "eye-guardian_1.3.0_x64_en-US.msi"

Write-Host "MSI 安装包位置:" -ForegroundColor Cyan
Write-Host "  $msiPath" -ForegroundColor White
Write-Host ""
Write-Host "文件名:" -ForegroundColor Cyan
Write-Host "  $msiFile" -ForegroundColor White
Write-Host ""

# 检查文件是否存在
if (Test-Path "$msiPath$msiFile") {
    $fileSize = (Get-Item "$msiPath$msiFile").Length / 1MB
    Write-Host "文件大小: $([Math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "下一步:" -ForegroundColor Cyan
    Write-Host "  1. 双击 MSI 文件安装应用" -ForegroundColor White
    Write-Host "  2. 或将 MSI 文件分发给用户" -ForegroundColor White
    Write-Host ""
    
    Write-Host "如需构建 Linux 版本:" -ForegroundColor Cyan
    Write-Host "  - 使用 WSL2 或 Linux 虚拟机" -ForegroundColor White
    Write-Host "  - 参考 BUILD_GUIDE.md" -ForegroundColor White
}
else {
    Write-Status "MSI 文件未找到，请检查构建日志" -Type Warning
}

Write-Host ""
Read-Host "按 Enter 键退出"
