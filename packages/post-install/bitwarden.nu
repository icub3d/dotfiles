do -i {
  mkdir ~/bin
  http get "https://vault.bitwarden.com/download/?app=cli&platform=linux" | save -f bw.zip
  unzip -o bw.zip -d ($nu.home-path | path join "bin") out> /dev/null
  chmod +x ~/bin/bw
  rm bw.zip
}
