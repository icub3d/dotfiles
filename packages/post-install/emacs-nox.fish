#!/usr/bin/fish

# pre-install our emacs packages.
if not test -d $HOME/.emacs.d
    /usr/bin/emacs -batch -l $HOME/.emacs
end
