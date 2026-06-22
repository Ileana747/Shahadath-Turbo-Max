# SHAHADATH TURBO MAX ⚡

  > Download anything. Faster. Smarter.

  A blazing-fast CLI video downloader with Normal, Turbo (8×), and MAX (16×) parallel download modes, a built-in AI assistant, cookie manager, and Telegram account linking.

  ---

  ## Quick Install

  **Linux / macOS / Termux (Android):**
  ```bash
  curl -sSL https://shahadath-serve.onrender.com/install.sh | bash
  ```

  **Windows (PowerShell):**
  ```powershell
  irm https://shahadath-serve.onrender.com/install.ps1 | iex
  ```

  ---

  ## Supported Platforms

  | Platform | Architecture | Status |
  |----------|-------------|--------|
  | Linux | amd64 (x86_64) | ✅ |
  | Linux | arm64 (aarch64) | ✅ |
  | Linux | armv7 (Raspberry Pi 2/3) | ✅ |
  | Linux | 386 (32-bit) | ✅ |
  | macOS | amd64 (Intel) | ✅ |
  | macOS | arm64 (M1/M2/M3) | ✅ |
  | Windows | amd64 | ✅ |
  | Windows | arm64 | ✅ |
  | Windows | 386 | ✅ |
  | Android (Termux) | arm64 | ✅ |
  | Android (Termux) | armv7 | ✅ |

  ---

  ## Commands

  ```
  shahadath <URL>                Download in normal mode
  shahadath turbo <URL>          8 parallel connections — faster
  shahadath max <URL>            16 parallel connections — maximum speed
  shahadath ai "query"           AI assistant mode
  shahadath link                 Show Telegram linking instructions
  shahadath link <CODE>          Link CLI to your Telegram account
  shahadath unlink               Unlink Telegram account
  shahadath cookie create <name> Create a cookie set from raw input
  shahadath cookie list          List saved cookie sets
  shahadath cookie use <name>    Set active cookie set
  shahadath status               Show account status and version info
  shahadath update               Self-update to latest version
  shahadath clean cache          Clear download cache
  ```

  ---

  ## Flags

  ```
  -q, --quality   Quality: best, 4k, 1080p, 720p, 480p, 360p, audio
  -f, --format    Output format: mp4, mkv, webm
  -o, --output    Output directory
  -c, --cookie    Cookie set to use for this download
  -a, --audio     Audio only (MP3)
  -p, --private   Private mode
  ```

  ---

  ## Link Telegram

  Turbo, MAX, and AI modes require your Telegram account to be linked.

  1. Run: `shahadath link`
  2. Open Telegram: [@Shahadath_TMax_bot](https://t.me/Shahadath_TMax_bot)
  3. Send `/start` to get your 8-character code
  4. Run: `shahadath link <YOUR_CODE>`

  ---

  ## AI Mode

  SHAHADATH includes an AI assistant that can search and download videos using natural language.

  ```bash
  shahadath ai "find me the latest Marvel trailer"
  shahadath ai "download best 4K music video by Kendrick Lamar"
  ```

  The AI will search, present results, and wait for your selection before downloading.

  ---

  ## Direct Binary Download

  ```
  https://shahadath-serve.onrender.com/bin/linux/amd64/shahadath
  https://shahadath-serve.onrender.com/bin/linux/arm64/shahadath
  https://shahadath-serve.onrender.com/bin/linux/armv7/shahadath
  https://shahadath-serve.onrender.com/bin/linux/386/shahadath
  https://shahadath-serve.onrender.com/bin/darwin/amd64/shahadath
  https://shahadath-serve.onrender.com/bin/darwin/arm64/shahadath
  https://shahadath-serve.onrender.com/bin/windows/amd64/shahadath.exe
  https://shahadath-serve.onrender.com/bin/windows/arm64/shahadath.exe
  https://shahadath-serve.onrender.com/bin/windows/386/shahadath.exe
  https://shahadath-serve.onrender.com/bin/android/arm64/shahadath
  https://shahadath-serve.onrender.com/bin/android/armv7/shahadath
  ```

  ---

  ## Telegram Bot

  [@Shahadath_TMax_bot](https://t.me/Shahadath_TMax_bot)

  | Command | Description |
  |---------|-------------|
  | `/start` | Get your SHAHADATH linking code |
  | `/code` | Resend your active linking code |

  ---

  *Binaries are pre-built for all platforms. Source code is private.*
  