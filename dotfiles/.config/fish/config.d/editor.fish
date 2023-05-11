#!/usr/bin/fish

set -U ALTERNATE_EDITOR ""

if command -vq nvim
  set -x EDITOR "nvim"
else if command -vq code
  set -x EDITOR "code --wait"
end
