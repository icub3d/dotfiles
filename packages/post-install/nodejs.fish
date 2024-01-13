#!/usr/bin/env fish

if test ! -f ~/.npmrc
	echo -en "prefix=/home/jmarsh/.npm-packages\n" >~/.npmrc
end

npm install --global yarn typescript neovim browser-sync json-server 
