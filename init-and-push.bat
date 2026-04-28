@echo off
chcp 65001 >nul
echo ========================================
echo Eye Guardian - Initialize and Push
echo ========================================
echo.

echo Step 1: Initialize Git repository
git init
echo.

echo Step 2: Add remote repository
git remote add origin https://github.com/tipsypedraza-boop/eye-guardian.git
echo.

echo Step 3: Check excluded files
echo The following will be excluded:
echo - go/ folder (~500MB)
echo - md files/ folder
echo - node_modules/
echo - build outputs (dist/, target/)
echo - binary files (*.exe, *.msi, *.deb)
echo.
pause

echo.
echo Step 4: Adding files...
git add .
echo.

echo Step 5: Files to be committed:
git status
echo.
pause

echo.
echo Step 6: Committing...
git commit -m "Initial commit: Fix GitHub Actions and clean project"
echo.

echo Step 7: Set main branch
git branch -M main
echo.

echo Step 8: Pushing to GitHub...
git push -u origin main
echo.

echo ========================================
echo Done!
echo ========================================
echo.
echo Next: Create tag to trigger auto build
echo   git tag v1.3.0
echo   git push origin v1.3.0
echo.
echo Then check: https://github.com/tipsypedraza-boop/eye-guardian/actions
echo.
pause
