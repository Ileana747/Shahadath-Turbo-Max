# SHAHADATH TURBO MAX — Windows PowerShell Installer
# Usage: irm https://shahadath-serve.onrender.com/install.ps1 | iex
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$BinaryBase = "https://shahadath-serve.onrender.com"
$BinaryName = "shahadath.exe"
$GitHubBase  = "https://github.com/Ileana747/Shahadath-Turbo-Max/releases/latest/download"

function Write-Step([string]$msg) {
    Write-Host "`n▶ $msg" -ForegroundColor Yellow
}
function Write-Ok([string]$msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Info([string]$msg) { Write-Host "  ▸ $msg" -ForegroundColor Cyan }
function Write-Warn([string]$msg) { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  ⚡ SHAHADATH TURBO MAX                  ║" -ForegroundColor Cyan
Write-Host "║     Video Downloader — Windows           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Detect architecture ───────────────────────────────────
Write-Step "Detecting environment"
$Arch = switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64" { "amd64" }
    "ARM64" { "arm64" }
    "x86"   { "386"   }
    default { "amd64" }
}
if ([Environment]::Is64BitOperatingSystem -and $Arch -eq "386") { $Arch = "amd64" }
Write-Info "Architecture: $Arch"
Write-Info "Windows $([System.Environment]::OSVersion.Version)"

# ── Install directory ─────────────────────────────────────
$InstallDir  = "$env:LOCALAPPDATA\Programs\shahadath"
$InstallPath = Join-Path $InstallDir $BinaryName
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Write-Info "Install directory: $InstallDir"

# ── Download binary ───────────────────────────────────────
Write-Step "Downloading binary"
$DownloadUrl = "$BinaryBase/bin/windows/$Arch/$BinaryName"
Write-Info "URL: $DownloadUrl"

$TmpFile = [System.IO.Path]::GetTempFileName() + ".exe"
$Downloaded = $false
$ProgressPreference = "SilentlyContinue"

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TmpFile -UseBasicParsing
    $FileSize = (Get-Item $TmpFile).Length
    if ($FileSize -lt 100000) { throw "File too small ($FileSize bytes)" }
    Write-Ok "Downloaded ($([math]::Round($FileSize / 1MB, 1)) MB)"
    $Downloaded = $true
} catch {
    Write-Warn "Primary download failed: $_"
    Write-Info "Trying GitHub Release fallback..."
    try {
        $FallbackUrl = "$GitHubBase/shahadath-windows-$Arch.exe"
        Invoke-WebRequest -Uri $FallbackUrl -OutFile $TmpFile -UseBasicParsing
        $FileSize = (Get-Item $TmpFile).Length
        if ($FileSize -lt 100000) { throw "File too small ($FileSize bytes)" }
        Write-Ok "Downloaded from GitHub ($([math]::Round($FileSize / 1MB, 1)) MB)"
        $Downloaded = $true
    } catch {
        Write-Host "`n  ✗ Download failed: $_" -ForegroundColor Red
        Write-Host "  Visit: https://github.com/Ileana747/Shahadath-Turbo-Max/releases" -ForegroundColor Yellow
        exit 1
    }
}
$ProgressPreference = "Continue"

# ── Install ───────────────────────────────────────────────
Write-Step "Installing"
Copy-Item -Path $TmpFile -Destination $InstallPath -Force
Remove-Item -Path $TmpFile -Force -ErrorAction SilentlyContinue
Write-Ok "Installed → $InstallPath"

# ── PATH ─────────────────────────────────────────────────
Write-Step "Updating PATH"
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path += ";$InstallDir"
    Write-Ok "Added $InstallDir to user PATH"
} else {
    Write-Ok "Already in PATH"
}

# ── Verify ────────────────────────────────────────────────
Write-Step "Verifying installation"
try {
    $v = & $InstallPath --version 2>$null
    Write-Ok "Binary OK${v:+: $v}"
} catch {
    Write-Info "Binary at $InstallPath — restart terminal to use"
}

# ── Done ─────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Installation complete!                  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. " -NoNewline; Write-Host "Restart this terminal" -ForegroundColor Yellow
Write-Host "  2. Link Telegram:  " -NoNewline; Write-Host "shahadath link" -ForegroundColor Cyan
Write-Host "     (get code from @Shahadath_TMax_bot)"
Write-Host "  3. Download video: " -NoNewline; Write-Host "shahadath https://youtu.be/..." -ForegroundColor Cyan
Write-Host "  4. Turbo mode:     " -NoNewline; Write-Host "shahadath turbo https://youtu.be/..." -ForegroundColor Cyan
Write-Host "  5. Help:           " -NoNewline; Write-Host "shahadath --help" -ForegroundColor Cyan
Write-Host ""
