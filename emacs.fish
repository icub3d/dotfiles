#!/usr/bin/fish

mkdir -p ~/dev
if not test -d ~/dev/emacs
	git clone https://git.savannah.gnu.org/git/emacs.git ~/dev/emacs
end

pushd ~/dev/emacs
./configure --without-mailutils -with-x-toolkit=lucid
make
sudo make install
popd

rm -rf ~/.emacs.d
/usr/local/bin/emacs -batch -l $HOME/.emacs >/dev/null ^/dev/null
