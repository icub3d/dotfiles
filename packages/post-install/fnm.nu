let npmrc = ($nu.home-dir | path join ".npmrc")
let npm_prefix = ($nu.home-dir | path join ".npm-packages")
if not ($npmrc | path exists) {
    $"prefix=($npm_prefix)\n" | save $npmrc
}

fnm install v24
fnm use v24

npm install --global typescript neovim
