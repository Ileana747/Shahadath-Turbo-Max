package main

  import (
      "fmt"
      "log"
      "net/http"
      "os"
      "strings"
  )

  const appVersion = "1.0.0"
  const ghRelease = "https://github.com/Ileana747/Shahadath-Turbo-Max/releases/download/v" + appVersion

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

  var rawBase = "https://raw.githubusercontent.com/Ileana747/Shahadath-Turbo-Max/main"

  func main() {
      port := os.Getenv("PORT")
      if port == "" {
          port = "8080"
      }

      mux := http.NewServeMux()

      mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Content-Type", "application/json")
          fmt.Fprintf(w, `{"status":"ok","version":"%s","service":"shahadath-binaries"}`, appVersion)
      })

      mux.HandleFunc("/install.sh", func(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Cache-Control", "no-cache")
          http.Redirect(w, r, rawBase+"/install.sh", http.StatusFound)
      })

      mux.HandleFunc("/install.ps1", func(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Cache-Control", "no-cache")
          http.Redirect(w, r, rawBase+"/install.ps1", http.StatusFound)
      })

      mux.HandleFunc("/version.json", func(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Cache-Control", "no-cache")
          http.Redirect(w, r, rawBase+"/version.json", http.StatusFound)
      })

      mux.HandleFunc("/latest-version.txt", func(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Cache-Control", "no-cache")
          http.Redirect(w, r, rawBase+"/latest-version.txt", http.StatusFound)
      })

      mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
          path := strings.TrimPrefix(r.URL.Path, "/")
          parts := strings.Split(path, "/")

          tryPlatform := func(osName, arch string) bool {
              platform := osName + "/" + arch
              if assetName, ok := binaryMap[platform]; ok {
                  http.Redirect(w, r, ghRelease+"/"+assetName, http.StatusFound)
                  return true
              }
              return false
          }

          // /{os}/{arch}/shahadath or /{os}/{arch}/shahadath.exe
          if len(parts) >= 2 {
              if tryPlatform(parts[0], parts[1]) {
                  return
              }
          }

          // /bin/{os}/{arch}/...
          if len(parts) >= 3 && parts[0] == "bin" {
              if tryPlatform(parts[1], parts[2]) {
                  return
              }
          }

          http.NotFound(w, r)
      })

      log.Printf("SHAHADATH binary server v%s listening on :%s", appVersion, port)
      log.Fatal(http.ListenAndServe(":"+port, mux))
  }
  