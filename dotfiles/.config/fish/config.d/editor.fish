#!/usr/bin/fish

set -U ALTERNATE_EDITOR ""
 
if command -vq nvim
  set -x EDITOR "nvim"
else if command -vq code
  set -x EDITOR "code --wait"
else if command -vq emacs; and not set -q PREFER_CODE
  set -x EDITOR "env TERM=xterm-24bit $EMACSCLIENTBIN -nw"
end
