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

# TODO may want to do this for desktop apps.
# Desktop files (used by desktop environments within both X11 and Wayland) are
# looked for in XDG_DATA_DIRS; make sure it includes the relevant directory for
# snappy applications' desktop files.
# snap_xdg_path="/var/lib/snapd/desktop"
# if [ -n "${XDG_DATA_DIRS##*${snap_xdg_path}}" ] && [ -n "${XDG_DATA_DIRS##*${snap_xdg_path}:*}" ]; then
#     export XDG_DATA_DIRS="${XDG_DATA_DIRS}:${snap_xdg_path}"
# fi
