do -i {
  if (not ("~/.npmrc" | path exists)) {
    echo "prefix=/home/jmarsh/.npm-packages\n" | save --append ~/.npmrc
  }

  npm install --global yarn typescript neovim browser-sync json-server 
}
