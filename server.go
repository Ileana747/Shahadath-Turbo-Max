package main

  import (
      "fmt"
      "log"
      "net/http"
      "os"
  )

  const appVersion = "1.0.0"
  const ghRelease = "https://github.com/Ileana747/Shahadath-Turbo-Max/releases/download/v" + appVersion
  const rawBase = "https://raw.githubusercontent.com/Ileana747/Shahadath-Turbo-Max/main"

  func redir(url string) http.HandlerFunc {
      return func(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Cache-Control", "no-cache")
          http.Redirect(w, r, url, http.StatusFound)
      }
  }

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

      mux.HandleFunc("/install.sh",        redir(rawBase+"/install.sh"))
      mux.HandleFunc("/install.ps1",       redir(rawBase+"/install.ps1"))
      mux.HandleFunc("/version.json",      redir(rawBase+"/version.json"))
      mux.HandleFunc("/latest-version.txt", redir(rawBase+"/latest-version.txt"))

      // Binary routes — explicit per platform (no string parsing)
      mux.HandleFunc("/linux/amd64/",   redir(ghRelease+"/shahadath-linux-amd64"))
      mux.HandleFunc("/linux/arm64/",   redir(ghRelease+"/shahadath-linux-arm64"))
      mux.HandleFunc("/linux/armv7/",   redir(ghRelease+"/shahadath-linux-armv7"))
      mux.HandleFunc("/linux/386/",     redir(ghRelease+"/shahadath-linux-386"))
      mux.HandleFunc("/linux/riscv64/", redir(ghRelease+"/shahadath-linux-riscv64"))
      mux.HandleFunc("/android/arm64/", redir(ghRelease+"/shahadath-android-arm64"))
      mux.HandleFunc("/android/armv7/", redir(ghRelease+"/shahadath-android-armv7"))
      mux.HandleFunc("/darwin/amd64/",  redir(ghRelease+"/shahadath-darwin-amd64"))
      mux.HandleFunc("/darwin/arm64/",  redir(ghRelease+"/shahadath-darwin-arm64"))
      mux.HandleFunc("/windows/amd64/", redir(ghRelease+"/shahadath-windows-amd64.exe"))
      mux.HandleFunc("/windows/arm64/", redir(ghRelease+"/shahadath-windows-arm64.exe"))
      mux.HandleFunc("/windows/386/",   redir(ghRelease+"/shahadath-windows-386.exe"))

      mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
          if r.URL.Path == "/" {
              w.Header().Set("Content-Type", "application/json")
              fmt.Fprintf(w, `{"service":"shahadath-binaries","version":"%s","install":"curl -sSL https://shahadath-serve.onrender.com/install.sh | bash"}`, appVersion)
              return
          }
          http.NotFound(w, r)
      })

      log.Printf("SHAHADATH v%s on :%s", appVersion, port)
      log.Fatal(http.ListenAndServe(":"+port, mux))
  }
  