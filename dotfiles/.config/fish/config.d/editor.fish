#!/usr/bin/fish

set -U ALTERNATE_EDITOR ""

if command -vq emacs
    set -x EDITOR "env TERM=xterm-24bit $EMACSCLIENTBIN -nw"
end
