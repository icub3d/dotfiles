#!/usr/bin/fish

function rust-binaries
	set -lx RUSTFLAGS -C target-cpu=native
	cargo install bandwhich \
		jwt-cli \
		my-ip \
		bat \
		bingrep \
		cargo-update \
		cargo-tree \
		cargo-outdated \
		cargo-upgrades \
		exa \
		ripgrep \
		git-delta \
		sd \
		hx \
		hyperfine \
		licensor \
		procs \
		ytop \
		du-dust \
		fd-find \
		wasm-pack \
		funzzy
	cargo install-update -a
end
