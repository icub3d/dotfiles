do -i {
  mkdir ~/bin

  # rust
  rustup toolchain add nightly
  rustup default stable
  rustup component add rust-analysis rust-src rust-analyzer
  rustup target add wasm32-unknown-unknown
  rustup component add --toolchain nightly rust-analysis rust-src rust-analyzer
  rustup target add --toolchain nightly wasm32-unknown-unknown
}
