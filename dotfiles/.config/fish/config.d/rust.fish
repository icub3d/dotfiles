#!/usr/bin/fish

set -x RUST_BACKTRACE 1

if test -d  $HOME/.cargo/bin
	set -x PATH $HOME/.cargo/bin $PATH
end
