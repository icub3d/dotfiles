#!/usr/bin/fish

set -U ALTERNATE_EDITOR ""

if command -vq emacs
    set -x EDITOR "emacs -nw"
end
