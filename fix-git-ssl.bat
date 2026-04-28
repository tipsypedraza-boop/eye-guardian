@echo off
chcp 65001 >nul
echo ========================================
echo Fix Git SSL/TLS Connection Issues
echo ========================================
echo.

echo Method 1: Disable SSL verification (temporary)
git config --global http.sslVerify false
echo SSL verification disabled
echo.

echo Method 2: Update Git SSL backend
git config --global http.sslBackend schannel
echo SSL backend set to schannel
echo.

echo Method 3: Set proxy settings (if needed)
echo If you're behind a proxy, uncomment and set:
echo git config --global http.proxy http://proxy:port
echo.

echo Trying to push again...
git push -u origin main
echo.

if %errorlevel% neq 0 (
    echo ========================================
    echo Push failed. Trying alternative method...
    echo ========================================
    echo.
    
    echo Using SSH instead of HTTPS
    git remote remove origin
    git remote add origin git@github.com:tipsypedraza-boop/eye-guardian.git
    echo.
    echo Remote changed to SSH. You may need to set up SSH keys.
    echo See: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
    echo.
) else (
    echo ========================================
    echo Success!
    echo ========================================
    echo.
    echo Next: Create release tag
    echo   git tag v1.3.0
    echo   git push origin v1.3.0
    echo.
)

pause
