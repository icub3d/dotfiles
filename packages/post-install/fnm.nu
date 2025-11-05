do -i {
  if (not ("~/.npmrc" | path exists)) {
    echo "prefix=/home/jmarsh/.npm-packages\n" | save --append ~/.npmrc
  }

  fnm install v24
  fnm use v24

  npm install --global typescript neovim
}
