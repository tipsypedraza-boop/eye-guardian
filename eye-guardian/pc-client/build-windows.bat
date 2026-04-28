@echo off
REM 护眼精灵 - Windows 打包脚本
REM 直接使用 Windows 现有依赖打包

setlocal enabledelayedexpansion

REM 颜色定义
set "GREEN=[92m"
set "BLUE=[94m"
set "RED=[91m"
set "YELLOW=[93m"
set "NC=[0m"

echo.
echo ========================================
echo 护眼精灵 - Windows 打包脚本
echo ========================================
echo.

REM 检查 Node.js
echo [检查] Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Node.js
    echo 请先安装 Node.js: https://nodejs.org/
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo [成功] Node.js %NODE_VERSION%

REM 检查 npm
echo [检查] npm...
npm --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 npm
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo [成功] npm %NPM_VERSION%

REM 检查 Rust
echo [检查] Rust...
cargo --version >nul 2>&1
if errorlevel 1 (
    echo [警告] 未找到 Rust
    echo.
    echo 需要安装 Rust 来构建 Tauri 应用
    echo 请选择:
    echo   1. 自动下载并安装 Rust
    echo   2. 手动安装（访问 https://rustup.rs/）
    echo   3. 取消
    echo.
    set /p CHOICE="请输入选择 (1-3): "
    
    if "!CHOICE!"=="1" (
        echo [信息] 下载 Rust 安装程序...
        powershell -Command "Invoke-WebRequest -Uri 'https://win.rustup.rs/x86_64' -OutFile 'rustup-init.exe'"
        echo [信息] 运行 Rust 安装程序...
        rustup-init.exe -y
        del rustup-init.exe
        call refreshenv
    ) else if "!CHOICE!"=="2" (
        echo [信息] 请访问 https://rustup.rs/ 安装 Rust
        echo [信息] 安装完成后，请重新运行此脚本
        pause
        exit /b 1
    ) else (
        echo [取消] 用户取消
        exit /b 1
    )
)
for /f "tokens=*" %%i in ('cargo --version') do set CARGO_VERSION=%%i
echo [成功] %CARGO_VERSION%

echo.
echo ========================================
echo 环境检查完成
echo ========================================
echo.

REM 创建图标
echo [步骤 1/5] 创建应用图标...
python create-placeholder-icons.py
if errorlevel 1 (
    echo [警告] 图标生成失败，继续使用默认图标
)
echo [成功] 图标准备完成
echo.

REM 安装前端依赖
echo [步骤 2/5] 安装前端依赖...
call npm install
if errorlevel 1 (
    echo [错误] npm install 失败
    pause
    exit /b 1
)
echo [成功] 前端依赖安装完成
echo.

REM 构建前端
echo [步骤 3/5] 构建前端资源...
call npm run build
if errorlevel 1 (
    echo [错误] 前端构建失败
    pause
    exit /b 1
)
echo [成功] 前端资源构建完成
echo.

REM 安装 Tauri CLI
echo [步骤 4/5] 安装 Tauri CLI...
cargo install tauri-cli
if errorlevel 1 (
    echo [错误] Tauri CLI 安装失败
    pause
    exit /b 1
)
echo [成功] Tauri CLI 安装完成
echo.

REM 构建应用
echo [步骤 5/5] 构建 Windows MSI 包...
cd src-tauri
cargo tauri build --target x86_64-pc-windows-msvc
if errorlevel 1 (
    echo [错误] 构建失败
    cd ..
    pause
    exit /b 1
)
cd ..
echo [成功] 构建完成
echo.

REM 显示结果
echo ========================================
echo 构建完成！
echo ========================================
echo.
echo MSI 安装包位置:
echo   src-tauri\target\x86_64-pc-windows-msvc\release\bundle\msi\
echo.
echo 文件名:
echo   eye-guardian_1.3.0_x64_en-US.msi
echo.
echo 下一步:
echo   1. 双击 MSI 文件安装应用
echo   2. 或将 MSI 文件分发给用户
echo.
echo 如需构建 Linux 版本:
echo   - 使用 WSL2 或 Linux 虚拟机
echo   - 参考 BUILD_GUIDE.md
echo.
pause
exit /b 0
