function tx
	command tmux new-session -d -c ~/.linux.d -s ld
	command tmux new-session -d -c ~ -s home
	command tmux new-session -d -c ~ -s emacs /usr/bin/fish -c 'env TERM=xterm-24bit /usr/local/bin/emacs --fg-daemon'
	command tmux new-session -d -c ~ -s srv -n srv1
	command tmux new-window -d -c ~ -t srv: -n srv2
	command tmux attach -t home
end
