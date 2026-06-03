mkdir ($nu.home-dir | path join "bin")

# Rust toolchains/components/targets — rustup is idempotent.
let toolchains = (rustup toolchain list)
let targets = (rustup target list --installed)

if not ($toolchains | str contains "nightly") {
    rustup toolchain add nightly
}
if not ($toolchains | str contains "stable") {
    rustup default stable
}

let active_components = (rustup component list --installed)
for comp in ["rust-analysis", "rust-src", "rust-analyzer"] {
    if not ($active_components | str contains $comp) {
        rustup component add $comp
    }
}
if not ($targets | str contains "wasm32-unknown-unknown") {
    rustup target add wasm32-unknown-unknown
}

let nightly_components = (rustup component list --toolchain nightly --installed)
for comp in ["rust-analysis", "rust-src", "rust-analyzer"] {
    if not ($nightly_components | str contains $comp) {
        rustup component add --toolchain nightly $comp
    }
}
let nightly_targets = (rustup target list --toolchain nightly --installed)
if not ($nightly_targets | str contains "wasm32-unknown-unknown") {
    rustup target add --toolchain nightly wasm32-unknown-unknown
}

if (which tree-sitter | is-empty) {
    cargo install tree-sitter-cli
}
