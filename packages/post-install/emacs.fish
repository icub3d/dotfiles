#!/usr/bin/fish

# pre-install our emacs packages.
if not test -d $HOME/.emacs.d
    $EMACSBIN -batch -l $HOME/.emacs >/dev/null ^/dev/null
end
