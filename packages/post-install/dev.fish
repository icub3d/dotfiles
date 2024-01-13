#!/usr/bin/fish

mkdir -p ~/bin

# update cli-tools
update-cli-tools

# install/update rust
if test ! -e ~/.cargo/bin/rustc
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	set -x PATH $HOME/.cargo/bin $PATH
	rustup toolchain add stable
	rustup toolchain add nightly
	rustup default stable
	rustup component add rust-analysis rust-src rust-analyzer
	rustup target add wasm32-unknown-unknown
	rustup component add --toolchain nightly rust-analysis rust-src rust-analyzer
	rustup target add --toolchain nightly wasm32-unknown-unknown
else
	rustup update
end

# ollama
if test ! -e /usr/local/bin/ollama
	curl https://ollama.ai/install.sh | sh
	ollama pull codellama
	ollama pull llama2
	ollama pull zephyr
end
