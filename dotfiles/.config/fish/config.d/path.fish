#!/usr/bin/fish

mkdir -p $HOME/bin/ $HOME/.local/bin
set -x PATH $HOME/bin $HOME/.local/bin $PATH

if test (uname -s) = "Darwin"
    set PATH /usr/local/opt/python@3.8/libexec/bin $PATH
end

if test -d $HOME/.neovim/bin
	set PATH $HOME/.neovim/bin $PATH
end

if test -d $HOME/dev/fortify/bin
	set PATH $HOME/dev/fortify/bin $PATH
end
