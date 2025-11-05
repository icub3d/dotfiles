rm -rf $nu.default-config-dir
ln -s ~/dev/dotfiles/nushell $nu.default-config-dir

sudo pacman -S rustup

rustup toolchain add stable

cd ~/dev
git clone https://aur.archlinux.org/fnm.git
cd fnm
makepkg -sic
fnm install v24

cd ~/dev/dotfiles
touch nushell/.env.nu

nu -c "source $nu.env-path; source $nu.config-path; update-system"
