rm -rf $nu.default-config-dir
ln -s ~/dev/dotfiles/nushell $nu.default-config-dir

cd ~/dev
git clone https://aur.archlinux.org/fnm.git
cd fnm
makepkg -sric
fnm install
cd ~/dev/dotfiles

#nu -c "source $nu.env-path; source $nu.config-path; update-system"
