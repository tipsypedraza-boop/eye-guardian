@echo off
chcp 65001 >nul
echo ========================================
echo Fix Git Setup and Push
echo ========================================
echo.

echo Step 1: Remove nested git repository
rmdir /s /q eye-guardian\.git
echo Removed eye-guardian/.git
echo.

echo Step 2: Update remote URL
echo Please enter your GitHub repository URL
echo Example: https://github.com/username/repo.git
set /p repo_url="Repository URL: "

git remote remove origin 2>nul
git remote add origin %repo_url%
echo.

echo Step 3: Re-add all files
git add .
echo.

echo Step 4: Check status
git status
echo.
pause

echo.
echo Step 5: Commit changes
git commit --amend -m "Initial commit: Eye Guardian project with GitHub Actions"
echo.

echo Step 6: Push to GitHub
git push -u origin main --force
echo.

echo ========================================
echo Done!
echo ========================================
echo.
echo Next: Create tag to trigger auto build
echo   git tag v1.3.0
echo   git push origin v1.3.0
echo.
pause
