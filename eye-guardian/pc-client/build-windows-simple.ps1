# Eye Guardian - Windows Build Script
# Simple version without encoding issues

Write-Host ""
Write-Host "========================================"
Write-Host "Eye Guardian - Windows Build"
Write-Host "========================================"
Write-Host ""

# Check Node.js
Write-Host "[Check] Node.js..." -ForegroundColor Cyan
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "[OK] Node.js $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Node.js not found" -ForegroundColor Red
    Write-Host "Please install Node.js: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check npm
Write-Host "[Check] npm..." -ForegroundColor Cyan
if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmVersion = npm --version
    Write-Host "[OK] npm $npmVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] npm not found" -ForegroundColor Red
    exit 1
}

# Check Rust
Write-Host "[Check] Rust..." -ForegroundColor Cyan
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    $cargoVersion = cargo --version
    Write-Host "[OK] $cargoVersion" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Rust not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Rust is required to build Tauri applications." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please install Rust:" -ForegroundColor Yellow
    Write-Host "  1. Visit https://rustup.rs/" -ForegroundColor White
    Write-Host "  2. Download rustup-init.exe" -ForegroundColor White
    Write-Host "  3. Run the installer" -ForegroundColor White
    Write-Host "  4. Restart PowerShell" -ForegroundColor White
    Write-Host "  5. Run this script again" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "Environment Check Complete"
Write-Host "========================================"
Write-Host ""

# Create icons
Write-Host "[Step 1/5] Creating application icons..." -ForegroundColor Cyan
try {
    python create-placeholder-icons.py
    Write-Host "[OK] Icons created" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Icon creation failed, using defaults" -ForegroundColor Yellow
}
Write-Host ""

# Install dependencies
Write-Host "[Step 2/5] Installing frontend dependencies..." -ForegroundColor Cyan
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Dependencies installed" -ForegroundColor Green
Write-Host ""

# Build frontend
Write-Host "[Step 3/5] Building frontend..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Frontend build failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Frontend built" -ForegroundColor Green
Write-Host ""

# Install Tauri CLI
Write-Host "[Step 4/5] Installing Tauri CLI..." -ForegroundColor Cyan
cargo install tauri-cli
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Tauri CLI installation failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Tauri CLI installed" -ForegroundColor Green
Write-Host ""

# Build application
Write-Host "[Step 5/5] Building Windows MSI package..." -ForegroundColor Cyan
Push-Location src-tauri
cargo tauri build --target x86_64-pc-windows-msvc
$buildResult = $LASTEXITCODE
Pop-Location

if ($buildResult -ne 0) {
    Write-Host "[ERROR] Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Build complete" -ForegroundColor Green
Write-Host ""

# Show results
Write-Host "========================================"
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""

$msiPath = "src-tauri\target\x86_64-pc-windows-msvc\release\bundle\msi\"
$msiFile = "eye-guardian_1.3.0_x64_en-US.msi"

Write-Host "MSI Package Location:" -ForegroundColor Cyan
Write-Host "  $msiPath" -ForegroundColor White
Write-Host ""
Write-Host "File Name:" -ForegroundColor Cyan
Write-Host "  $msiFile" -ForegroundColor White
Write-Host ""

if (Test-Path "$msiPath$msiFile") {
    $fileSize = (Get-Item "$msiPath$msiFile").Length / 1MB
    Write-Host "File Size: $([Math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Double-click the MSI file to install" -ForegroundColor White
    Write-Host "  2. Or distribute the MSI file to users" -ForegroundColor White
} else {
    Write-Host "[WARNING] MSI file not found" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
