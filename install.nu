mkdir ~/.config/nushell
ln -s ~/dev/dotfiles/dotfiles/.config/nushell/env.nu ~/.config/nushell/env.nu
ln -s ~/dev/dotfiles/dotfiles/.config/nushell/config.nu ~/.config/nushell/config.nu

source $nu.env-path
source $nu.config-path

update
