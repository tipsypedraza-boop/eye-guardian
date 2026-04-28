@echo off
REM 护眼精灵 - 占位符图标生成器 (Windows 批处理版本)

echo ========================================
echo 护眼精灵 - 占位符图标生成器
echo ========================================
echo.

REM 检查 Python 是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Python，请先安装 Python
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [信息] 正在生成占位符图标...
echo.

REM 运行 Python 脚本
python create-placeholder-icons.py

if errorlevel 1 (
    echo.
    echo [错误] 图标生成失败
    echo.
    echo 如果提示缺少 Pillow 库，请运行:
    echo   pip install Pillow
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo 完成！
echo ========================================
pause
