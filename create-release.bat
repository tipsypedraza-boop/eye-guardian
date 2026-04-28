@echo off
chcp 65001 >nul
echo ========================================
echo Create Release Tag
echo ========================================
echo.

echo Current tags:
git tag
echo.

set /p version="Enter version (e.g., 1.3.1): "
if "%version%"=="" (
    echo Error: Version is required
    pause
    exit /b 1
)

set tag=v%version%

echo.
echo Creating tag: %tag%
git tag %tag%
echo.

echo Pushing tag to GitHub...
git push origin %tag%
echo.

if %errorlevel% equ 0 (
    echo ========================================
    echo Success!
    echo ========================================
    echo.
    echo Tag %tag% created and pushed
    echo.
    echo GitHub Actions will now build:
    echo - Windows MSI and NSIS installers
    echo - Linux DEB package
    echo - macOS DMG image
    echo.
    echo Check build status:
    echo https://github.com/tipsypedraza-boop/eye-guardian/actions
    echo.
    echo Release will be available at:
    echo https://github.com/tipsypedraza-boop/eye-guardian/releases/tag/%tag%
    echo.
) else (
    echo ========================================
    echo Failed to push tag
    echo ========================================
    echo.
)

pause
