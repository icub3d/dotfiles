#!/usr/bin/env fish

if test ! -f ~/.npmrc
	echo -en "prefix=/home/jmarsh/.npm-packages\nregistry=https://npm.marsh.gg\n" >~/.npmrc
end

npm install --global yarn typescript-language-server pyright typescript yaml-language-server neovim emmet-ls browser-sync
