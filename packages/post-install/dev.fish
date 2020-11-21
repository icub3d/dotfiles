#!/usr/bin/fish

# install/update rust
if test ! -e ~/.cargo/bin/rustc
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	set -x PATH $HOME/.cargo/bin $PATH
	rustup toolchain add nightly
	rustup component add rls rust-analysis rust-src
else
	rustup update
end

rust-binaries

# istio
wget -Oistio.tar.gz https://github.com/istio/istio/releases/download/1.8.0/istio-1.8.0-linux-amd64.tar.gz
tar -x -C ~/bin/ --strip-components=2 -f istio.tar.gz istio-1.8.0/bin/istioctl
rm istio.tar.gz
