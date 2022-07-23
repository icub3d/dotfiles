#!/usr/bin/fish

# install/update rust
if test ! -e ~/.cargo/bin/rustc
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	set -x PATH $HOME/.cargo/bin $PATH
	rustup toolchain add stable
	rustup default stable
	rustup component add rust-analysis rust-src
else
	rustup update
end

rustup target add wasm32-unknown-unknown

# Haskell
if test ! -e ~/.ghcup
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
end
ghcup install ghc 9.2.3
ghcup install cabal 3.6.2.0
ghcup install stack 2.7.5

# python
python -m venv ~/.python
~/.python/bin/pip install pandas numpy matplotlib pynvim debugpy
