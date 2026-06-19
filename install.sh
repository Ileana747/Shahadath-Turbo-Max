#!/usr/bin/env bash
# ============================================================
# SHAHADATH TURBO MAX — Installation Script
# ============================================================
set -euo pipefail

BINARY_NAME="shahadath"
BINARY_BASE="https://shahadath-serve.onrender.com"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${CYAN}  ▸${NC} $*"; }
ok()      { echo -e "${GREEN}  ✓${NC} $*"; }
warn()    { echo -e "${YELLOW}  ⚠${NC} $*"; }
die()     { echo -e "\n${RED}  ✗ ERROR:${NC} $*\n" >&2; exit 1; }
step()    { echo -e "\n${BOLD}${BLUE}▶${NC}${BOLD} $*${NC}"; }

# ── Banner ────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}⚡ SHAHADATH TURBO MAX${NC}                  ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║${NC}     ${DIM}Video Downloader — All Platforms${NC}     ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── Detect OS ────────────────────────────────────────────
step "Detecting environment"
OS=""
IS_TERMUX=false
IS_WSL=false

if [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]; then
  OS="android"
  IS_TERMUX=true
  ok "Termux (Android)"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  OS="darwin"
  ok "macOS $(sw_vers -productVersion 2>/dev/null || true)"
elif [[ "$(uname -s)" == "Linux" ]]; then
  OS="linux"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
    ok "Linux (WSL)"
  else
    ok "Linux"
  fi
else
  die "Unsupported OS: $(uname -s). Use the Windows PowerShell script for Windows."
fi

# ── Detect Architecture ───────────────────────────────────
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64)          ARCH="amd64"   ;;
  aarch64|arm64|armv8l)  ARCH="arm64"   ;;
  armv7l|armv7|armhf)    ARCH="armv7"   ;;
  i386|i686|x86)         ARCH="386"     ;;
  riscv64)               ARCH="riscv64" ;;
  *) die "Unsupported architecture: ${ARCH}. Open an issue at https://github.com/Ileana747/Shahadath-Turbo-Max" ;;
esac
info "Architecture: ${ARCH}"

# ── Determine install directory ───────────────────────────
PLATFORM="${OS}"
DOWNLOAD_URL="${BINARY_BASE}/bin/${PLATFORM}/${ARCH}/${BINARY_NAME}"
info "Platform: ${PLATFORM}/${ARCH}"

if [[ "${IS_TERMUX}" == "true" ]]; then
  INSTALL_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"
elif [[ "${OS}" == "darwin" ]]; then
  INSTALL_DIR="/usr/local/bin"
else
  if [[ -w "/usr/local/bin" ]] || sudo -n true 2>/dev/null; then
    INSTALL_DIR="/usr/local/bin"
  else
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "${INSTALL_DIR}"
  fi
fi
info "Install directory: ${INSTALL_DIR}"

# ── Runtime engine check ─────────────────────────────────
step "Checking runtime engines"

install_deps_termux() {
  echo -ne "${DIM}    Getting extractor engine...${NC}"
  pkg install -y python python-pip 2>/dev/null 1>/dev/null && \
    pip install -q yt-dlp 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(skip)${NC}"

  echo -ne "${DIM}    Getting downloader engine...${NC}"
  pkg install -y aria2 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(skip)${NC}"

  echo -ne "${DIM}    Getting merger engine...${NC}"
  pkg install -y ffmpeg 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(skip)${NC}"
}

install_deps_linux() {
  local PM=""
  if command -v apt-get &>/dev/null; then PM="apt"
  elif command -v dnf &>/dev/null; then PM="dnf"
  elif command -v yum &>/dev/null; then PM="yum"
  elif command -v pacman &>/dev/null; then PM="pacman"
  elif command -v brew &>/dev/null; then PM="brew"
  fi

  local NEED_YTDLP=false
  local NEED_ARIA2=false
  local NEED_FFMPEG=false

  command -v yt-dlp   &>/dev/null || NEED_YTDLP=true
  command -v aria2c   &>/dev/null || NEED_ARIA2=true
  command -v ffmpeg   &>/dev/null || NEED_FFMPEG=true

  if [[ "${NEED_YTDLP}" == "false" ]] && [[ "${NEED_ARIA2}" == "false" ]] && [[ "${NEED_FFMPEG}" == "false" ]]; then
    ok "All engines present"
    return
  fi

  if [[ "${NEED_YTDLP}" == "true" ]]; then
    echo -ne "${DIM}    Getting extractor engine...${NC}"
    if command -v pip3 &>/dev/null || command -v pip &>/dev/null; then
      (pip3 install -q yt-dlp 2>/dev/null || pip install -q yt-dlp 2>/dev/null) && \
        echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(manual install needed)${NC}"
    elif command -v pipx &>/dev/null; then
      pipx install yt-dlp 2>/dev/null 1>/dev/null && \
        echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}(manual install needed)${NC}"
    else
      echo -e " ${YELLOW}(install python3-pip first)${NC}"
    fi
  fi

  if [[ "${NEED_ARIA2}" == "true" ]] && [[ -n "${PM}" ]]; then
    echo -ne "${DIM}    Getting downloader engine...${NC}"
    case "${PM}" in
      apt)    (sudo apt-get install -y -qq aria2 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
      dnf|yum)(${PM} install -y -q aria2 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
      pacman) (sudo pacman -S --noconfirm --quiet aria2 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
      brew)   (brew install aria2 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
    esac
  fi

  if [[ "${NEED_FFMPEG}" == "true" ]] && [[ -n "${PM}" ]]; then
    echo -ne "${DIM}    Getting merger engine...${NC}"
    case "${PM}" in
      apt)    (sudo apt-get install -y -qq ffmpeg 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
      dnf|yum)(${PM} install -y -q ffmpeg 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
      pacman) (sudo pacman -S --noconfirm --quiet ffmpeg 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
      brew)   (brew install ffmpeg 2>/dev/null 1>/dev/null && echo -e " ${GREEN}✓${NC}") || echo -e " ${YELLOW}(skip)${NC}" ;;
    esac
  fi
}

if [[ "${IS_TERMUX}" == "true" ]]; then
  install_deps_termux
elif [[ "${OS}" == "linux" ]]; then
  install_deps_linux
elif [[ "${OS}" == "darwin" ]]; then
  install_deps_linux
fi

# ── Check for downloader ──────────────────────────────────
DOWNLOADER=""
if command -v curl &>/dev/null; then
  DOWNLOADER="curl"
elif command -v wget &>/dev/null; then
  DOWNLOADER="wget"
else
  die "Neither curl nor wget found. Install one and try again."
fi

# ── Download binary ───────────────────────────────────────
step "Downloading binary"
info "URL: ${DOWNLOAD_URL}"

TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

if [[ "${DOWNLOADER}" == "curl" ]]; then
  HTTP_CODE=$(curl -sSL --fail --write-out "%{http_code}" -o "${TMP_FILE}" "${DOWNLOAD_URL}" 2>/dev/null) || HTTP_CODE="000"
else
  HTTP_CODE=$(wget -q --server-response -O "${TMP_FILE}" "${DOWNLOAD_URL}" 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}') || HTTP_CODE="000"
fi

if [[ "${HTTP_CODE}" != "200" ]]; then
  echo ""
  warn "Direct download failed (HTTP ${HTTP_CODE})"
  info "Trying GitHub Release fallback..."
  GH_URL="https://github.com/Ileana747/Shahadath-Turbo-Max/releases/latest/download/shahadath-${OS}-${ARCH}"
  [[ "${OS}" == "windows" ]] && GH_URL="${GH_URL}.exe"
  if [[ "${DOWNLOADER}" == "curl" ]]; then
    HTTP_CODE=$(curl -sSL --fail --write-out "%{http_code}" -o "${TMP_FILE}" "${GH_URL}" 2>/dev/null) || HTTP_CODE="000"
  else
    HTTP_CODE=$(wget -q --server-response -O "${TMP_FILE}" "${GH_URL}" 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}') || HTTP_CODE="000"
  fi
  [[ "${HTTP_CODE}" != "200" ]] && die "Download failed. Visit: https://github.com/Ileana747/Shahadath-Turbo-Max/releases"
fi

if [[ ! -s "${TMP_FILE}" ]]; then
  die "Downloaded file is empty. Server may be starting up — try again in 30 seconds."
fi

FILESIZE=$(wc -c < "${TMP_FILE}" 2>/dev/null || echo 0)
if (( FILESIZE < 100000 )); then
  die "Downloaded file too small (${FILESIZE} bytes). Possible error page. Try again."
fi

ok "Downloaded ($(( FILESIZE / 1024 / 1024 )) MB)"

# ── Install binary ────────────────────────────────────────
step "Installing"
chmod +x "${TMP_FILE}"

if [[ -w "${INSTALL_DIR}" ]]; then
  mv "${TMP_FILE}" "${INSTALL_DIR}/${BINARY_NAME}"
else
  sudo mv "${TMP_FILE}" "${INSTALL_DIR}/${BINARY_NAME}"
fi
trap - EXIT

ok "Installed → ${INSTALL_DIR}/${BINARY_NAME}"

# ── PATH check ────────────────────────────────────────────
if ! command -v "${BINARY_NAME}" &>/dev/null; then
  echo ""
  warn "${INSTALL_DIR} is not in PATH"
  echo -e "  Add to your shell config:"
  echo -e "  ${DIM}export PATH=\"\$PATH:${INSTALL_DIR}\"${NC}"
fi

# ── Verify ────────────────────────────────────────────────
step "Verifying installation"
if command -v "${BINARY_NAME}" &>/dev/null; then
  VER=$("${BINARY_NAME}" --version 2>/dev/null || true)
  ok "Binary OK${VER:+: ${VER}}"
else
  info "Binary at ${INSTALL_DIR}/${BINARY_NAME} — restart terminal to use"
fi

# ── Done ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}Installation complete!${NC}                  ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  ${CYAN}1.${NC} Link Telegram:   ${BOLD}shahadath link${NC}"
echo -e "     ${DIM}(get code from @Shahadath_TMax_bot)${NC}"
echo -e "  ${CYAN}2.${NC} Download video:  ${BOLD}shahadath https://youtu.be/...${NC}"
echo -e "  ${CYAN}3.${NC} Turbo mode:      ${BOLD}shahadath turbo https://youtu.be/...${NC}"
echo -e "  ${CYAN}4.${NC} AI assistant:    ${BOLD}shahadath ai <query>${NC}"
echo -e "  ${CYAN}5.${NC} Help:            ${BOLD}shahadath --help${NC}"
echo ""
