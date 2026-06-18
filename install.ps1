# SHAHADATH TURBO MAX — Windows PowerShell Installer
# Usage: irm https://shahadath-turbo-max.onrender.com/install.ps1 | iex
# Requires: PowerShell 5.1+ or PowerShell 7+

$ErrorActionPreference = "Stop"

$BinaryName = "shahadath.exe"
$BinaryBase = "https://shahadath-turbo-max.onrender.com"

Write-Host ""
Write-Host "⚡ SHAHADATH TURBO MAX — Windows Installer" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Detect architecture
$Arch = switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64"   { "amd64" }
    "ARM64"   { "arm64" }
    "x86"     { "386"   }
    default   { "amd64" }
}

if ([Environment]::Is64BitOperatingSystem -and $Arch -eq "386") {
    $Arch = "amd64"
}

Write-Host "[INFO] Architecture: $Arch" -ForegroundColor Gray

$DownloadURL = "$BinaryBase/bin/windows/$Arch/$BinaryName"
Write-Host "[INFO] Download URL: $DownloadURL" -ForegroundColor Gray

# Install directory
$InstallDir = "$env:LOCALAPPDATA\Programs\shahadath"
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$InstallPath = Join-Path $InstallDir $BinaryName
Write-Host "[INFO] Install path: $InstallPath" -ForegroundColor Gray

# Download
Write-Host "[INFO] Downloading shahadath..." -ForegroundColor Gray
try {
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallPath -UseBasicParsing
    $ProgressPreference = "Continue"
    Write-Host "[OK] Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Download failed: $_" -ForegroundColor Red
    Write-Host "[INFO] Trying alternate download..." -ForegroundColor Yellow
    exit 1
}

# Verify download
if (-not (Test-Path $InstallPath) -or (Get-Item $InstallPath).Length -lt 1KB) {
    Write-Host "[ERROR] Downloaded file is invalid." -ForegroundColor Red
    exit 1
}

# Add to PATH
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($CurrentPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$CurrentPath;$InstallDir",
        "User"
    )
    Write-Host "[OK] Added $InstallDir to PATH" -ForegroundColor Green
    Write-Host "[INFO] Restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
}

# Verify
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Gray
try {
    & $InstallPath --version 2>$null
    Write-Host "[OK] Installation complete!" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Binary installed but could not run yet. Open a new terminal." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Restart terminal or run: `$env:Path += ';$InstallDir'"
Write-Host "  2. Link Telegram: shahadath link"
Write-Host "     (Get code from @Shahadath_TMax_bot on Telegram)"
Write-Host "  3. Download: shahadath https://youtu.be/..."
Write-Host "  4. Help: shahadath --help"
Write-Host ""
