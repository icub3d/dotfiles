#!/usr/bin/fish

function rust-binaries
	set -lx RUSTFLAGS -C target-cpu=native
	cargo install --locked bandwhich \
		jwt-cli \
		my-ip \
		bat \
		bingrep \
		cargo-edit \
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
		du-dust \
		fd-find \
		wasm-pack \
		funzzy \
		trunk \
		tmux-status-tracker
	cargo install-update -a
end
