function tx
	command tmux new-session -d -c ~/dev/dotfiles -s dot
	command tmux new-session -d -c ~ -s home
	command tmux new-session -d -c ~ -s emacs /usr/bin/fish -c 'env TERM=xterm-24bit /usr/bin/emacs --fg-daemon'
	if test (cat /etc/hostname) = "work"
		command tmux new-session -d -c ~/dev/oti -s oti
		command tmux new-session -d -c ~/dev/oti-azure -s oti-azure
	else
		command tmux new-session -d -c ~ -s srv -n srv1
		command tmux new-window -d -c ~ -t srv: -n srv2
	end
	command tmux attach -t home
end
