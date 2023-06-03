#/usr/bin/env fish

if !test -d ~/dev/emacs
    mkdir -p ~/dev/emacs
    pushd ~/dev
    gh repo clone emacs-mirror/emacs.git
    pushd emacs
    git checkout emacs-29
    popd
    popd
end

pushd ~/dev/emacs
./autogen.sh
./configure ./configure --with-native-compilation=aot --with-tree-sitter \
    --with-gif --with-png --with-jpeg --with-rsvg --with-tiff \
    --with-imagemagick --with-x-toolkit=gtk3 --with-xwidgets
make
sudo make install
popd

if !test -d ~/dev/tree-sitter-module
    mkdir -p ~/dev/tree-sitter-module
    pushd ~/dev/
    gh repo clone casouri/tree-sitter-module.git
    popd
end

pushd ~/dev/tree-sitter-module
./batch.sh
pushd dist
ln -s libtree-sitter-go-mod.so libtree-sitter-gomod.so
mkdir -p ~/.config/emacs/tree-sitter
cp * ~/.config/emacs/tree-sitter
popd
popd
