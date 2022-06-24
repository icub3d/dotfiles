#!/usr/bin/env fish

# install fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# install some plugins
fisher install PatrickF1/fzf.fish
