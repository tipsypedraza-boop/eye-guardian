# Clean and Push to GitHub Script
# Encoding: UTF-8

Write-Host "=== Eye Guardian - Clean and Push to GitHub ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check Git status
Write-Host "1. Checking Git status..." -ForegroundColor Yellow
git status

Write-Host ""
Write-Host "=== Files to be excluded ===" -ForegroundColor Red
Write-Host "- go/ (Go source code, ~500MB+)"
Write-Host "- md files/ (temporary docs)"
Write-Host "- node_modules/ (dependencies)"
Write-Host "- **/target/ (Rust build output)"
Write-Host "- **/dist/ (frontend build output)"
Write-Host "- *.zip, *.exe, *.msi, *.deb (binary files)"
Write-Host ""

# 2. Confirm
$confirm = Read-Host "Continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Red
    exit
}

# 3. Add all files (.gitignore will exclude automatically)
Write-Host ""
Write-Host "2. Adding files to Git..." -ForegroundColor Yellow
git add .

# 4. Show files to be committed
Write-Host ""
Write-Host "3. Files to be committed:" -ForegroundColor Yellow
git status

# 5. Commit
Write-Host ""
$commitMsg = Read-Host "Enter commit message (default: 'Fix GitHub Actions and clean project')"
if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $commitMsg = "Fix GitHub Actions and clean project"
}

Write-Host ""
Write-Host "4. Committing changes..." -ForegroundColor Yellow
git commit -m "$commitMsg"

# 6. Push
Write-Host ""
Write-Host "5. Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Create tag to trigger auto build" -ForegroundColor Cyan
Write-Host "  git tag v1.3.0"
Write-Host "  git push origin v1.3.0"
Write-Host ""
