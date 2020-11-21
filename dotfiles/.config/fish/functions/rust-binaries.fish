#!/usr/bin/fish

function rust-binaries
	cargo install bandwhich \
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
