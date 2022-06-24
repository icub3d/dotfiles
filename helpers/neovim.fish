#!/usr/bin/fish

if command -qv pacman
	sudo pacman -S base-devel cmake unzip ninja
else if command -qv apt-get
	sudo apt-get install ninja-build gettext libtool libtool-bin \
		autoconf automake cmake g++ pkg-config unzip
else if (uname -s) = "Darwin"
	brew install ninja libtool automake cmake pkg-config gettext
end

if not test -d ~/dev/neovim
	git clone https://github.com/neovim/neovim ~/dev/neovim
end

pushd ~/dev/neovim
mkdir -p $HOME/.neovim
rm -r build/
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.neovim"
make install
popd

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
