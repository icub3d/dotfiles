mkdir ($nu.home-dir | path join "bin")

# Rust toolchains/components/targets — rustup is idempotent.
rustup toolchain add nightly
rustup default stable
rustup component add rust-analysis rust-src rust-analyzer
rustup target add wasm32-unknown-unknown
rustup component add --toolchain nightly rust-analysis rust-src rust-analyzer
rustup target add --toolchain nightly wasm32-unknown-unknown

if (which tree-sitter | is-empty) {
  cargo install tree-sitter-cli
}
