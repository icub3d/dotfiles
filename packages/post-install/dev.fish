#!/usr/bin/fish

# install/update rust
if test ! -e ~/.cargo/bin/rustc
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	set -x PATH $HOME/.cargo/bin $PATH
	rustup toolchain add stable
	rustup toolchain add nightly
	rustup default stable
	rustup component add rls rust-analysis rust-src
else
	rustup update
end

rust-binaries
