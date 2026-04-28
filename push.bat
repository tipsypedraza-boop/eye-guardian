@echo off
chcp 65001 >nul
echo ========================================
echo Eye Guardian - Push to GitHub
echo ========================================
echo.

echo Excluded files:
echo - go/ folder
echo - md files/ folder
echo - node_modules/
echo - build outputs
echo.

pause

echo.
echo Adding files...
git add .

echo.
echo Files to commit:
git status

echo.
set /p commit_msg="Enter commit message (or press Enter for default): "
if "%commit_msg%"=="" set commit_msg=Fix GitHub Actions and clean project

echo.
echo Committing...
git commit -m "%commit_msg%"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo ========================================
echo Done!
echo ========================================
echo.
echo Next: Create tag to trigger build
echo   git tag v1.3.0
echo   git push origin v1.3.0
echo.
pause
