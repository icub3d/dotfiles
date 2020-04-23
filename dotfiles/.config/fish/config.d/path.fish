#!/usr/bin/fish

mkdir -p $HOME/bin/ $HOME/.local/bin
set -x PATH $HOME/bin $HOME/.local/bin $PATH

if test (uname -s) = "Darwin"
    set PATH /usr/local/opt/python@3.8/libexec/bin $PATH
end
