#!/usr/bin/fish

mkdir -p ~/bin

if test "$DISTRO" = "Ubuntu"
  # stern
  if test ! -e ~/bin/stern
    wget -O $HOME/bin/stern https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
    chmod +x ~/bin/stern
  end

  # k9s
  if test ! -e ~/bin/k9s
    wget -O- \
      https://github.com/derailed/k9s/releases/download/v0.26.3/k9s_Linux_x86_64.tar.gz | \
            tar -xz -C ~/bin k9s
  end

  # kubectl
  if test ! -e ~/bin/kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl ~/bin
  end
end

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

if test ! -d ~/.python
  python -m venv $HOME/.python
  source ~/.python/bin/activate.fish
  pip install debugpy
end


# hey
if test ! -e ~/bin/hey
	wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
	chmod +x hey_linux_amd64
	mv hey_linux_amd64 ~/bin/hey
end


# dap stuff
if test ! -e ~/dev/vscode-chrome-debug
	git clone https://github.com/microsoft/vscode-chrome-debug ~/dev/vscode-chrome-debug
	pushd ~/dev/vscode-chrome-debug
	npm install
	npm run build
	popd
end

if test ! -e ~/dev/vscode-firefox-debug
	git clone https://github.com/firefox-devtools/vscode-firefox-debug ~/dev/vscode-firefox-debug
	pushd ~/dev/vscode-chrome-debug
	npm install
	npm run build
	popd
end

if test ! -e ~/bin/bw
	install-bitwarden-cli
end
