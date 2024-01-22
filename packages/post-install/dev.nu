mkdir ~/bin

update-cli-tools

# rust
if (not ("~/.cargo/bin/rustc" | path exists)) {
	http get https://sh.rustup.rs | sh -s -- -y
  $env.PATH = ($env.PATH | append "~/.cargo/bin")
	rustup toolchain add stable
	rustup toolchain add nightly
	rustup default stable
	rustup component add rust-analysis rust-src rust-analyzer
	rustup target add wasm32-unknown-unknown
	rustup component add --toolchain nightly rust-analysis rust-src rust-analyzer
	rustup target add --toolchain nightly wasm32-unknown-unknown
} else {
  rustup update
}

# ollama
if (not ("/usr/local/bin/ollama" | path exists)) {
  http get https://ollama.ai/install.sh | sh
	ollama pull codellama
	ollama pull llama2
	ollama pull zephyr
}

