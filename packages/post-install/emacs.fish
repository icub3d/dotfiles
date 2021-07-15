#!/usr/bin/fish

# pre-install our emacs packages.
if not test -d $HOME/.emacs.d/elpa
    $EMACSBIN -batch -l $HOME/emacs.d/init.el >/dev/null 2>/dev/null
end
