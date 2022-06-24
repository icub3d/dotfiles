#!/usr/bin/fish

mkdir -p ~/dev
if not test -d ~/dev/emacs
	git clone https://git.savannah.gnu.org/git/emacs.git ~/dev/emacs
end

pushd ~/dev/emacs
git checkout emacs-28
git pull
./autogen.sh
./configure --without-mailutils -with-x-toolkit=lucid
make
sudo make install
popd

rm -rf ~/.emacs.d/auto-save-list/  ~/.emacs.d/backups/  ~/.emacs.d/elpa
/usr/local/bin/emacs -batch -l $HOME/.emacs >/dev/null 2>/dev/null
