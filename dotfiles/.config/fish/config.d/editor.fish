#!/usr/bin/fish

set -U ALTERNATE_EDITOR ""
 
if command -vq nvim
  set -x EDITOR "nvim"
end
