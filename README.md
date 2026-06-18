# SHAHADATH TURBO MAX ⚡

> Download anything. Faster. Smarter. No bullshit.

A blazing-fast CLI video downloader with normal, turbo (8x), and MAX (16x) parallel download modes, built-in AI assistant (Groq), cookie manager, and Telegram account linking.

---

## Quick Install

**Linux / macOS / Termux (Android):**
```bash
curl -sSL https://shahadath-turbo-max.onrender.com/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://shahadath-turbo-max.onrender.com/install.ps1 | iex
```

---

## Supported Platforms

| Platform | Architecture | Status |
|----------|-------------|--------|
| Linux | amd64 (x86_64) | ✅ |
| Linux | arm64 (aarch64) | ✅ |
| Linux | armv7 (Raspberry Pi 2/3) | ✅ |
| Linux | 386 (32-bit) | ✅ |
| Linux | riscv64 | ✅ |
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
shahadath <URL>              Download (normal mode, yt-dlp)
shahadath turbo <URL>        8 parallel connections (aria2c)
shahadath max <URL>          16 parallel connections — max speed
shahadath ai "query"         AI assistant (requires Groq API key)
shahadath link <CODE>        Link to Telegram (@Shahadath_TMax_bot)
shahadath unlink             Unlink Telegram account
shahadath cookie create      Add browser cookies
shahadath cookie list        List saved cookies
shahadath cookie use <name>  Set active cookie
shahadath status             Show linked account, version
shahadath update             Update to latest version
shahadath config set <k> <v> Set config value
shahadath clean              Clean caches/downloads
```

---

## Flags (all commands)

```
-q, --quality   Video quality: best, 1080p, 720p, 480p, audio, mp3
-f, --format    Output format: mp4, mkv, webm
-o, --output    Output directory
-c, --cookie    Cookie file to use
-a, --audio     Audio only (MP3)
-p, --private   Private mode (rate-limited)
```

---

## Link Telegram

1. Start [@Shahadath_TMax_bot](https://t.me/Shahadath_TMax_bot)
2. Send `/start` — you get an 8-character code
3. Run: `shahadath link <CODE>`

This links your CLI to your Telegram account. Usage is tracked privately.

---

## AI Mode

Requires a [Groq API key](https://console.groq.com/keys) (free):

```bash
export GROQ_API_KEY=your_key_here
shahadath ai "summarise this YouTube video: https://youtu.be/..."
```

---

## Direct Binary Download

```
https://shahadath-turbo-max.onrender.com/bin/linux/amd64/shahadath
https://shahadath-turbo-max.onrender.com/bin/linux/arm64/shahadath
https://shahadath-turbo-max.onrender.com/bin/linux/armv7/shahadath
https://shahadath-turbo-max.onrender.com/bin/linux/386/shahadath
https://shahadath-turbo-max.onrender.com/bin/darwin/amd64/shahadath
https://shahadath-turbo-max.onrender.com/bin/darwin/arm64/shahadath
https://shahadath-turbo-max.onrender.com/bin/windows/amd64/shahadath.exe
https://shahadath-turbo-max.onrender.com/bin/windows/arm64/shahadath.exe
https://shahadath-turbo-max.onrender.com/bin/android/arm64/shahadath
https://shahadath-turbo-max.onrender.com/bin/android/armv7/shahadath
```

---

## Requirements

| Tool | Purpose | Install |
|------|---------|---------|
| `yt-dlp` | Video extraction | `pip install yt-dlp` |
| `aria2c` | Turbo/Max downloads | `apt install aria2` |

---

## Telegram Bot

[@Shahadath_TMax_bot](https://t.me/Shahadath_TMax_bot)

Commands:
- `/start` — Get linking code
- `/code` — Resend your current code
- `/help` — How to link

---

*Source code is private. Binaries are pre-built and provided for all platforms.*
