#!/usr/bin/fish

# install/update rust
if test ! -e ~/.cargo/bin/rustc
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	set -x PATH $HOME/.cargo/bin $PATH
	rustup install nightly
else
	rustup update
end
