#!/usr/bin/fish

mkdir -p $HOME/bin/ $HOME/.local/bin
set -x PATH $HOME/bin $HOME/.local/bin $PATH

if test -d $HOME/.npm-packages/bin/
	set PATH $HOME/.npm-packages/bin/ $PATH
end

if test -d $HOME/.neovim/bin
	set PATH $HOME/.neovim/bin $PATH
end

if test -d /usr/local/bin
	set PATH $PATH /usr/local/bin
end

if test -d /usr/local/go/bin
	set PATH $PATH /usr/local/go/bin
end

if test -d /usr/local/opt/findutils/libexec/gnubin
	set PATH $PATH /usr/local/opt/findutils/libexec/gnubin
end

for p in emulator platform-tools cmdline-tools/latest/bin
	if test -d /opt/android-sdk/$p
		set PATH $PATH /opt/android-sdk/$p
	end
end
