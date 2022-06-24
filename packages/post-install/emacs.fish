#!/usr/bin/fish

# pre-install our emacs packages.
if not test -d $HOME/.emacs.d/elpa
    $EMACSBIN -batch -l $HOME/emacs.d/init.el >/dev/null 2>/dev/null
end

mkdir -p ~/.pandoc/templates
wget -O$HOME/.pandoc/templates/GitHub.html5 https://raw.githubusercontent.com/tajmone/pandoc-goodies/master/templates/html5/github/GitHub.html5
