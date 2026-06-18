#!/usr/bin/env bash
# ============================================================
# SHAHADATH TURBO MAX — Installation Script
# Usage: curl -sSL https://shahadath-turbo-max.onrender.com/install.sh | bash
# ============================================================
set -euo pipefail

BINARY_NAME="shahadath"
BINARY_BASE="https://shahadath-serve.onrender.com"
VERSION_URL="${BINARY_BASE}/latest-version.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

echo ""
echo -e "${BOLD}⚡ SHAHADATH TURBO MAX — Installer${NC}"
echo "============================================"

# ── Detect OS ────────────────────────────────────────────────
OS=""
IS_TERMUX=false
IS_WSL=false

if [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]; then
  OS="android"
  IS_TERMUX=true
  info "Detected: Termux (Android)"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  OS="darwin"
  info "Detected: macOS"
elif [[ "$(uname -s)" == "Linux" ]]; then
  OS="linux"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
    info "Detected: Linux (WSL)"
  else
    info "Detected: Linux"
  fi
else
  die "Unsupported OS: $(uname -s). Use the Windows PowerShell script for Windows."
fi

# ── Detect Architecture ───────────────────────────────────────
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64)       ARCH="amd64" ;;
  aarch64|arm64)      ARCH="arm64" ;;
  armv7l|armv7|armhf) ARCH="armv7" ;;
  i386|i686|x86)      ARCH="386"   ;;
  riscv64)            ARCH="riscv64" ;;
  *)                  die "Unsupported architecture: ${ARCH}" ;;
esac
info "Architecture: ${ARCH}"

# ── Determine download URL ────────────────────────────────────
if [[ "${OS}" == "android" ]]; then
  PLATFORM="android"
else
  PLATFORM="${OS}"
fi

DOWNLOAD_URL="${BINARY_BASE}/bin/${PLATFORM}/${ARCH}/${BINARY_NAME}"
info "Download URL: ${DOWNLOAD_URL}"

# ── Determine install directory ───────────────────────────────
if [[ "${IS_TERMUX}" == "true" ]]; then
  INSTALL_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"
elif [[ "${OS}" == "darwin" ]]; then
  INSTALL_DIR="/usr/local/bin"
else
  # Linux / WSL: prefer /usr/local/bin, fall back to ~/.local/bin
  if [[ -w "/usr/local/bin" ]] || sudo -n true 2>/dev/null; then
    INSTALL_DIR="/usr/local/bin"
  else
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "${INSTALL_DIR}"
  fi
fi
info "Install directory: ${INSTALL_DIR}"

# ── Check for curl/wget ───────────────────────────────────────
DOWNLOADER=""
if command -v curl &>/dev/null; then
  DOWNLOADER="curl"
elif command -v wget &>/dev/null; then
  DOWNLOADER="wget"
else
  die "Neither curl nor wget found. Install one and try again."
fi

# ── Download binary ───────────────────────────────────────────
TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

info "Downloading ${BINARY_NAME}..."
if [[ "${DOWNLOADER}" == "curl" ]]; then
  HTTP_CODE=$(curl -sSL --fail --write-out "%{http_code}" -o "${TMP_FILE}" "${DOWNLOAD_URL}" 2>/dev/null) || true
else
  HTTP_CODE=$(wget -q --server-response -O "${TMP_FILE}" "${DOWNLOAD_URL}" 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}') || true
fi

if [[ "${HTTP_CODE}" != "200" ]]; then
  warn "Pre-built binary not available for ${PLATFORM}/${ARCH} (HTTP ${HTTP_CODE})"
  warn "Trying to build from source..."
  build_from_source
fi

if [[ ! -s "${TMP_FILE}" ]]; then
  die "Downloaded file is empty. Something went wrong."
fi

# ── Install binary ────────────────────────────────────────────
chmod +x "${TMP_FILE}"

if [[ -w "${INSTALL_DIR}" ]]; then
  mv "${TMP_FILE}" "${INSTALL_DIR}/${BINARY_NAME}"
else
  sudo mv "${TMP_FILE}" "${INSTALL_DIR}/${BINARY_NAME}"
fi
trap - EXIT

success "Installed to ${INSTALL_DIR}/${BINARY_NAME}"

# ── Add to PATH if needed ─────────────────────────────────────
if ! command -v "${BINARY_NAME}" &>/dev/null; then
  warn "${INSTALL_DIR} is not in PATH"
  warn "Add it: export PATH=\"\$PATH:${INSTALL_DIR}\""
  warn "Or add that line to ~/.bashrc / ~/.zshrc"
fi

# ── Verify installation ───────────────────────────────────────
echo ""
echo -e "${BOLD}Verifying...${NC}"
if command -v "${BINARY_NAME}" &>/dev/null; then
  "${BINARY_NAME}" --version 2>/dev/null || true
  success "Installation complete!"
else
  warn "Binary installed but not in PATH yet. Restart your terminal or run:"
  echo "  export PATH=\"\$PATH:${INSTALL_DIR}\""
fi

# ── Post-install instructions ─────────────────────────────────
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. Link your Telegram: ${CYAN}shahadath link${NC}"
echo -e "     (Visit @Shahadath_TMax_bot to get your code)"
echo -e "  2. Download a video:   ${CYAN}shahadath https://youtu.be/...${NC}"
echo -e "  3. Turbo mode:         ${CYAN}shahadath turbo https://youtu.be/...${NC}"
echo -e "  4. See all commands:   ${CYAN}shahadath --help${NC}"
echo ""

build_from_source() {
  if ! command -v go &>/dev/null; then
    die "Go is not installed. Install Go from https://go.dev/dl/ and retry."
  fi
  TMP_SRC="$(mktemp -d)"
  trap 'rm -rf "${TMP_SRC}"' EXIT
  info "Cloning source..."
  git clone --depth=1 https://github.com/Ileana747/Shahadath-Turbo-Max "${TMP_SRC}" 2>/dev/null || \
    die "Could not clone source. Check your internet connection."
  info "Building..."
  cd "${TMP_SRC}"
  GOPROXY="https://proxy.golang.org,direct" GONOSUMDB="*" CGO_ENABLED=0 \
    go build -ldflags="-s -w" -trimpath -o "${TMP_FILE}" . 2>/dev/null || \
    die "Build failed."
  cd -
  HTTP_CODE="200"
}
