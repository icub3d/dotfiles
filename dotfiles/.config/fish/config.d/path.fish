#!/usr/bin/fish

mkdir -p $HOME/bin/ $HOME/.local/bin
set -x PATH $HOME/bin $HOME/.local/bin $PATH

if test -d $HOME/.npm-packages/bin/
	set PATH $HOME/.npm-packages/bin/ $PATH
end

if test (uname -s) = "Darwin"
    set PATH /usr/local/opt/python@3.8/libexec/bin $PATH
end

if test -d $HOME/.neovim/bin
	set PATH $HOME/.neovim/bin $PATH
end

if test -d $HOME/dev/fortify/bin
	set PATH $HOME/dev/fortify/bin $PATH
end

if test -d /var/lib/snapd/snap/bin
	set PATH $PATH /var/lib/snapd/snap/bin
end

if test -d $HOME/sonar-scanner/bin/
	set PATH $PATH $HOME/sonar-scanner/bin/
end

if test -d /usr/local/opt/node@14/bin
	set PATH $PATH /usr/local/opt/node@14/bin
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

if test -d $HOME/.cabal/bin
	set PATH $PATH $HOME/.cabal/bin
end

if test -d $HOME/.ghcup/bin
	set PATH $PATH $HOME/.ghcup/bin
end

if test -d $HOME/.local/share/gem/ruby/3.0.0/bin
  set PATH $PATH $HOME/.local/share/gem/ruby/3.0.0/bin
end

if test -d $HOME/.rvm/bin
  set PATH $PATH $HOME/.rvm/bin
end

if test -d $HOME/.python/bin
  set PATH $PATH $HOME/.python/bin 
end

# TODO may want to do this for desktop apps.
# Desktop files (used by desktop environments within both X11 and Wayland) are
# looked for in XDG_DATA_DIRS; make sure it includes the relevant directory for
# snappy applications' desktop files.
# snap_xdg_path="/var/lib/snapd/desktop"
# if [ -n "${XDG_DATA_DIRS##*${snap_xdg_path}}" ] && [ -n "${XDG_DATA_DIRS##*${snap_xdg_path}:*}" ]; then
#     export XDG_DATA_DIRS="${XDG_DATA_DIRS}:${snap_xdg_path}"
# fi
