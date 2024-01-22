mkdir ~/.config/nushell

rm -f ~/.config/nushell/env.nu
rm -f ~/.config/nushell/config.nu

ln -s ~/dev/dotfiles/dotfiles/.config/nushell/env.nu ~/.config/nushell/env.nu
ln -s ~/dev/dotfiles/dotfiles/.config/nushell/config.nu ~/.config/nushell/config.nu

nu -c update-system
