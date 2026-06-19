//go:build server

package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

const version = "1.0.0"
const ghRelease = "https://github.com/Ileana747/Shahadath-Turbo-Max/releases/download/v" + version
const serverBase = "https://shahadath-serve.onrender.com"

// binaryMap maps "platform/arch" → GitHub Release asset name
var binaryMap = map[string]string{
	"linux/amd64":   "shahadath-linux-amd64",
	"linux/arm64":   "shahadath-linux-arm64",
	"linux/armv7":   "shahadath-linux-armv7",
	"linux/386":     "shahadath-linux-386",
	"linux/riscv64": "shahadath-linux-riscv64",
	"android/arm64": "shahadath-android-arm64",
	"android/armv7": "shahadath-android-armv7",
	"darwin/amd64":  "shahadath-darwin-amd64",
	"darwin/arm64":  "shahadath-darwin-arm64",
	"windows/amd64": "shahadath-windows-amd64.exe",
	"windows/arm64": "shahadath-windows-arm64.exe",
	"windows/386":   "shahadath-windows-386.exe",
}

var installSH = `#!/usr/bin/env bash
# SHAHADATH TURBO MAX — Installation Script
# Usage: curl -sSL https://shahadath-serve.onrender.com/install.sh | bash
set -euo pipefail

BINARY_NAME="shahadath"
BINARY_BASE="https://shahadath-serve.onrender.com"
GH_BASE="https://github.com/Ileana747/Shahadath-Turbo-Max/releases/latest/download"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

info()  { echo -e "${CYAN}  ▸${NC} $*"; }
ok()    { echo -e "${GREEN}  ✓${NC} $*"; }
warn()  { echo -e "${YELLOW}  ⚠${NC} $*"; }
die()   { echo -e "\n${RED}  ✗ ERROR:${NC} $*\n" >&2; exit 1; }
step()  { echo -e "\n${BOLD}▶ $*${NC}"; }

echo ""; echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}⚡ SHAHADATH TURBO MAX${NC}                  ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║${NC}     ${DIM}Video Downloader — All Platforms${NC}     ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"; echo ""

step "Detecting environment"
IS_TERMUX=false
if [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]; then
  IS_TERMUX=true; OS="android"; ok "Termux (Android)"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  OS="darwin"; ok "macOS"
elif [[ "$(uname -s)" == "Linux" ]]; then
  OS="linux"; ok "Linux"
else
  die "Unsupported OS. Use the Windows PowerShell script."
fi

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64)         ARCH="amd64"   ;;
  aarch64|arm64|armv8l) ARCH="arm64"   ;;
  armv7l|armv7|armhf)   ARCH="armv7"   ;;
  i386|i686|x86)        ARCH="386"     ;;
  riscv64)              ARCH="riscv64" ;;
  *) die "Unsupported architecture: ${ARCH}" ;;
esac
info "Platform: ${OS}/${ARCH}"

if [[ "${IS_TERMUX}" == "true" ]]; then
  INSTALL_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"
elif [[ "${OS}" == "darwin" ]]; then
  INSTALL_DIR="/usr/local/bin"
else
  if [[ -w "/usr/local/bin" ]] || sudo -n true 2>/dev/null; then
    INSTALL_DIR="/usr/local/bin"
  else
    INSTALL_DIR="${HOME}/.local/bin"; mkdir -p "${INSTALL_DIR}"
  fi
fi
info "Install dir: ${INSTALL_DIR}"

step "Checking runtime engines"
if [[ "${IS_TERMUX}" == "true" ]]; then
  echo -ne "${DIM}    Getting extractor engine...${NC}"
  pkg install -y python python-pip 2>/dev/null 1>/dev/null && \
    pip install -q yt-dlp 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(skip)${NC}"
  echo -ne "${DIM}    Getting downloader engine...${NC}"
  pkg install -y aria2 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(skip)${NC}"
  echo -ne "${DIM}    Getting merger engine...${NC}"
  pkg install -y ffmpeg 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(skip)${NC}"
else
  command -v yt-dlp &>/dev/null && ok "Extractor engine present" || {
    echo -ne "${DIM}    Getting extractor engine...${NC}"
    (pip3 install -q yt-dlp 2>/dev/null || pip install -q yt-dlp 2>/dev/null) && \
      echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(install manually: pip install yt-dlp)${NC}"
  }
  command -v aria2c &>/dev/null && ok "Downloader engine present" || \
    warn "Downloader engine missing — install aria2 for turbo/max mode"
  command -v ffmpeg &>/dev/null && ok "Merger engine present" || \
    warn "Merger engine missing — install ffmpeg for format conversion"
fi

step "Downloading binary"
TMP_FILE="$(mktemp)"; trap 'rm -f "${TMP_FILE}"' EXIT
DOWNLOAD_URL="${BINARY_BASE}/bin/${OS}/${ARCH}/${BINARY_NAME}"
info "URL: ${DOWNLOAD_URL}"

HTTP_CODE=$(curl -sSL --fail --write-out "%{http_code}" -o "${TMP_FILE}" "${DOWNLOAD_URL}" 2>/dev/null) || HTTP_CODE="000"
if [[ "${HTTP_CODE}" != "200" ]]; then
  warn "Primary download failed (HTTP ${HTTP_CODE}) — trying GitHub..."
  GH_URL="${GH_BASE}/shahadath-${OS}-${ARCH}"
  HTTP_CODE=$(curl -sSL --fail --write-out "%{http_code}" -o "${TMP_FILE}" "${GH_URL}" 2>/dev/null) || HTTP_CODE="000"
  [[ "${HTTP_CODE}" != "200" ]] && die "Download failed. Visit: https://github.com/Ileana747/Shahadath-Turbo-Max/releases"
fi
[[ ! -s "${TMP_FILE}" ]] && die "Downloaded file is empty."
FSIZE=$(wc -c < "${TMP_FILE}"); (( FSIZE < 100000 )) && die "File too small (${FSIZE}B) — server may be starting up, retry in 30s"
ok "Downloaded ($(( FSIZE / 1024 / 1024 ))MB)"

step "Installing"
chmod +x "${TMP_FILE}"
if [[ -w "${INSTALL_DIR}" ]]; then mv "${TMP_FILE}" "${INSTALL_DIR}/${BINARY_NAME}"
else sudo mv "${TMP_FILE}" "${INSTALL_DIR}/${BINARY_NAME}"; fi
trap - EXIT
ok "Installed → ${INSTALL_DIR}/${BINARY_NAME}"

! command -v "${BINARY_NAME}" &>/dev/null && \
  warn "${INSTALL_DIR} not in PATH — add: export PATH=\"\$PATH:${INSTALL_DIR}\""

echo ""; echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║  Installation complete!                  ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${NC}"; echo ""
echo -e "  ${CYAN}1.${NC} Link Telegram:  ${BOLD}shahadath link${NC}  (get code from @Shahadath_TMax_bot)"
echo -e "  ${CYAN}2.${NC} Download:       ${BOLD}shahadath https://youtu.be/...${NC}"
echo -e "  ${CYAN}3.${NC} Turbo mode:     ${BOLD}shahadath turbo https://youtu.be/...${NC}"
echo -e "  ${CYAN}4.${NC} AI assistant:   ${BOLD}shahadath ai <query>${NC}"
echo -e "  ${CYAN}5.${NC} Help:           ${BOLD}shahadath --help${NC}"; echo ""
`

var installPS1 = `# SHAHADATH TURBO MAX — Windows PowerShell Installer
# Usage: irm https://shahadath-serve.onrender.com/install.ps1 | iex
$BinaryBase  = "https://shahadath-serve.onrender.com"
$GHBase      = "https://github.com/Ileana747/Shahadath-Turbo-Max/releases/latest/download"
$BinaryName  = "shahadath.exe"
$InstallDir  = "$env:LOCALAPPDATA\Programs\shahadath"
$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"

function Step([string]$m) { Write-Host "`n▶ $m" -ForegroundColor Yellow }
function Ok([string]$m)   { Write-Host "  ✓ $m" -ForegroundColor Green }
function Info([string]$m) { Write-Host "  ▸ $m" -ForegroundColor Cyan }

Write-Host ""; Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  ⚡ SHAHADATH TURBO MAX                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan; Write-Host ""

Step "Detecting environment"
$Arch = switch ($env:PROCESSOR_ARCHITECTURE) { "AMD64" {"amd64"} "ARM64" {"arm64"} "x86" {"386"} default {"amd64"} }
if ([Environment]::Is64BitOperatingSystem -and $Arch -eq "386") { $Arch = "amd64" }
Info "Architecture: $Arch"

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
$InstallPath = Join-Path $InstallDir $BinaryName

Step "Downloading binary"
$TmpFile = [IO.Path]::GetTempFileName() + ".exe"
$Url = "$BinaryBase/bin/windows/$Arch/$BinaryName"
Info "URL: $Url"
try {
  Invoke-WebRequest -Uri $Url -OutFile $TmpFile -UseBasicParsing
  $sz = (Get-Item $TmpFile).Length
  if ($sz -lt 100000) { throw "too small ($sz bytes)" }
  Ok "Downloaded ($([math]::Round($sz/1MB,1))MB)"
} catch {
  Write-Host "  ⚠ Primary failed, trying GitHub..." -ForegroundColor Yellow
  Invoke-WebRequest -Uri "$GHBase/shahadath-windows-$Arch.exe" -OutFile $TmpFile -UseBasicParsing
  Ok "Downloaded from GitHub"
}

Step "Installing"
Copy-Item $TmpFile $InstallPath -Force; Remove-Item $TmpFile -Force -EA SilentlyContinue
Ok "Installed → $InstallPath"

Step "Updating PATH"
$p = [Environment]::GetEnvironmentVariable("Path","User")
if ($p -notlike "*$InstallDir*") {
  [Environment]::SetEnvironmentVariable("Path","$p;$InstallDir","User"); $env:Path += ";$InstallDir"
  Ok "Added to PATH"
} else { Ok "Already in PATH" }

Write-Host ""; Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Installation complete! Restart terminal  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green; Write-Host ""
Write-Host "  1. Link Telegram:  " -NoNewline; Write-Host "shahadath link" -ForegroundColor Cyan
Write-Host "     (get code from @Shahadath_TMax_bot)"
Write-Host "  2. Download:       " -NoNewline; Write-Host "shahadath https://youtu.be/..." -ForegroundColor Cyan
Write-Host "  3. Help:           " -NoNewline; Write-Host "shahadath --help" -ForegroundColor Cyan
Write-Host ""
`

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fsBinaries := http.FileServer(http.Dir("./binaries"))
	mux := http.NewServeMux()

	// ── Health check ──────────────────────────────────────────────────────────
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"status":"ok","service":"shahadath-binaries","version":"%s","ts":%d}`,
			version, time.Now().UnixMilli())
	})

	// ── Version JSON ─────────────────────────────────────────────────────────
	mux.HandleFunc("/version.json", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
		base := serverBase + "/bin"
		data := map[string]interface{}{
			"version":      version,
			"force_update": false,
			"changelog":    "Initial release — Normal/Turbo/Max modes, AI assistant, Cookie manager, Telegram linking",
			"released_at":  "2026-06-19",
			"downloads": map[string]string{
				"linux/amd64":   base + "/linux/amd64/shahadath",
				"linux/arm64":   base + "/linux/arm64/shahadath",
				"linux/armv7":   base + "/linux/armv7/shahadath",
				"linux/386":     base + "/linux/386/shahadath",
				"linux/riscv64": base + "/linux/riscv64/shahadath",
				"android/arm64": base + "/android/arm64/shahadath",
				"android/armv7": base + "/android/armv7/shahadath",
				"darwin/amd64":  base + "/darwin/amd64/shahadath",
				"darwin/arm64":  base + "/darwin/arm64/shahadath",
				"windows/amd64": base + "/windows/amd64/shahadath.exe",
				"windows/arm64": base + "/windows/arm64/shahadath.exe",
				"windows/386":   base + "/windows/386/shahadath.exe",
			},
			"install_sh":  serverBase + "/install.sh",
			"install_ps1": serverBase + "/install.ps1",
		}
		_ = json.NewEncoder(w).Encode(data)
	})

	// ── Version text ─────────────────────────────────────────────────────────
	mux.HandleFunc("/latest-version.txt", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		w.Header().Set("Cache-Control", "no-cache")
		fmt.Fprintln(w, version)
	})

	// ── Install scripts (embedded) ────────────────────────────────────────────
	mux.HandleFunc("/install.sh", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
		fmt.Fprint(w, installSH)
	})

	mux.HandleFunc("/install.ps1", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
		fmt.Fprint(w, installPS1)
	})

	// ── Binary downloads ──────────────────────────────────────────────────────
	// Supports both:
	//   /bin/{platform}/{arch}/{binary}    (canonical)
	//   /{platform}/{arch}/{binary}        (legacy compat)
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		path := strings.TrimPrefix(r.URL.Path, "/")
		parts := strings.Split(path, "/")

		// /bin/platform/arch/binary
		if len(parts) >= 4 && parts[0] == "bin" {
			platform := parts[1] + "/" + parts[2]
			if assetName, ok := binaryMap[platform]; ok {
				http.Redirect(w, r, ghRelease+"/"+assetName, http.StatusFound)
				return
			}
		}

		// /platform/arch/binary (legacy)
		if len(parts) >= 3 {
			platform := parts[0] + "/" + parts[1]
			if assetName, ok := binaryMap[platform]; ok {
				http.Redirect(w, r, ghRelease+"/"+assetName, http.StatusFound)
				return
			}
		}

		http.StripPrefix("/", fsBinaries).ServeHTTP(w, r)
	})

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      mux,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	log.Printf("Shahadath binary server v%s starting on :%s", version, port)
	log.Fatal(srv.ListenAndServe())
}
