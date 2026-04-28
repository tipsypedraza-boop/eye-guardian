@echo off
chcp 65001 >nul
echo ========================================
echo Quick Push to GitHub
echo ========================================
echo.

echo Step 1: Add all changes
git add .
echo.

echo Step 2: Show status
git status
echo.

set /p commit_msg="Commit message (default: Update project): "
if "%commit_msg%"=="" set commit_msg=Update project

echo.
echo Step 3: Commit
git commit -m "%commit_msg%"
echo.

echo Step 4: Push to GitHub
git push origin main
echo.

if %errorlevel% equ 0 (
    echo ========================================
    echo Success!
    echo ========================================
    echo.
    echo View at: https://github.com/tipsypedraza-boop/eye-guardian
    echo.
) else (
    echo ========================================
    echo Push failed. Trying to pull first...
    echo ========================================
    echo.
    git pull origin main --rebase
    echo.
    echo Retrying push...
    git push origin main
    echo.
)

pause
