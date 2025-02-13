mkdir ~/.config/nushell

rm -f ~/.config/nushell/env.nu
rm -f ~/.config/nushell/config.nu
rm -f ~/.config/nushell/linux.nu
rm -f ~/.config/nushell/macos.nu

ln -s ~/dev/dotfiles/dotfiles/.config/nushell/env.nu ~/.config/nushell/env.nu
ln -s ~/dev/dotfiles/dotfiles/.config/nushell/config.nu ~/.config/nushell/config.nu
ln -s ~/dev/dotfiles/dotfiles/.config/nushell/linux.nu ~/.config/nushell/linux.nu
ln -s ~/dev/dotfiles/dotfiles/.config/nushell/macos.nu ~/.config/nushell/macos.nu

cd ~/dev
git clone https://aur.archlinux.org/fnm.git
cd fnm
makepkg -sric
cd ~/dev/dotfiles

nu -c "source $nu.env-path; source $nu.config-path; update-system"
