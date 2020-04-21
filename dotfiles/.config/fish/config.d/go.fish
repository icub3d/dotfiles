#!/usr/bin/fish

if test -d /usr/lib/go/bin
	set -x PATH /usr/lib/go/bin $PATH
end

mkdir -p $HOME/go/bin
set -x PATH $HOME/go/bin $PATH 
