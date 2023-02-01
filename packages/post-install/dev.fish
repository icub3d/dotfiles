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

# Nerd Fonts 
fish ./helpers/jet-brains-mono.fish

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
