@echo off
chcp 65001 >nul
echo ========================================
echo Start Fresh - Push to GitHub
echo ========================================
echo.

echo Step 1: Initialize new Git repository
git init
echo.

echo Step 2: Add remote
git remote add origin https://github.com/tipsypedraza-boop/eye-guardian.git
echo.

echo Step 3: Add all files (excluding large files via .gitignore)
git add .
echo.

echo Step 4: Show what will be committed
git status
echo.
echo Check the list above. Large folders should NOT appear.
pause

echo.
echo Step 5: Commit
git commit -m "Initial commit: Eye Guardian with GitHub Actions"
echo.

echo Step 6: Set branch to main
git branch -M main
echo.

echo Step 7: Push to GitHub
echo Note: If repository doesn't exist, create it first at:
echo https://github.com/new
echo.
pause

git push -u origin main
echo.

echo ========================================
echo Done!
echo ========================================
echo.
echo Next: Create release tag
echo   git tag v1.3.0
echo   git push origin v1.3.0
echo.
echo Check Actions at:
echo https://github.com/tipsypedraza-boop/eye-guardian/actions
echo.
pause
