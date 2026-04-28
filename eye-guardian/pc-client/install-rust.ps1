# Install Rust for Windows
# This script downloads and installs Rust automatically

Write-Host ""
Write-Host "========================================"
Write-Host "Rust Installation Script"
Write-Host "========================================"
Write-Host ""

# Check if Rust is already installed
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    $cargoVersion = cargo --version
    Write-Host "[INFO] Rust is already installed: $cargoVersion" -ForegroundColor Green
    Write-Host ""
    $reinstall = Read-Host "Do you want to reinstall? (y/n)"
    if ($reinstall -ne "y") {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "[Step 1/3] Downloading Rust installer..." -ForegroundColor Cyan
$rustupUrl = "https://win.rustup.rs/x86_64"
$rustupInstaller = "$env:TEMP\rustup-init.exe"

try {
    Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupInstaller -ErrorAction Stop
    Write-Host "[OK] Downloaded rustup-init.exe" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to download Rust installer" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download manually from: https://rustup.rs/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[Step 2/3] Running Rust installer..." -ForegroundColor Cyan
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
Write-Host ""

try {
    # Run installer with default options (-y flag)
    & $rustupInstaller -y
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Rust installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Rust installation failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to run installer" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
} finally {
    # Clean up installer
    if (Test-Path $rustupInstaller) {
        Remove-Item $rustupInstaller -Force
    }
}

Write-Host ""
Write-Host "[Step 3/3] Verifying installation..." -ForegroundColor Cyan

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Add Cargo bin to current session PATH
$cargoPath = "$env:USERPROFILE\.cargo\bin"
if (Test-Path $cargoPath) {
    $env:Path = "$cargoPath;$env:Path"
}

# Verify installation
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    $rustcVersion = rustc --version
    $cargoVersion = cargo --version
    Write-Host "[OK] $rustcVersion" -ForegroundColor Green
    Write-Host "[OK] $cargoVersion" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Rust installed but not found in PATH" -ForegroundColor Yellow
    Write-Host "Please restart PowerShell and try again" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================"
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Close this PowerShell window" -ForegroundColor White
Write-Host "  2. Open a new PowerShell window" -ForegroundColor White
Write-Host "  3. Run: .\build-windows-simple.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Or run the build script now (may require restart)" -ForegroundColor Yellow
Write-Host ""

$runNow = Read-Host "Run build script now? (y/n)"
if ($runNow -eq "y") {
    Write-Host ""
    Write-Host "Starting build..." -ForegroundColor Cyan
    & .\build-windows-simple.ps1
} else {
    Write-Host "Please restart PowerShell and run: .\build-windows-simple.ps1" -ForegroundColor Yellow
}
