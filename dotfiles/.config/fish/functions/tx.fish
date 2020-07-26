function tx
	command tmux new-session -d -c ~/dev/dotfiles -s dot
	command tmux new-session -d -c ~ -s home
	
	command tmux new-session -d -c ~ -s emacs $FISHBIN -c 'env TERM=xterm-24bit $EMACSBIN --fg-daemon'

	if test "$ATWORK" = "true"
		command tmux new-session -d -c ~/dev/oti -s oti
		command tmux new-session -d -c ~/dev/oti-azure -s oti-az
	else
		command tmux new-session -d -c ~ -s srv -n srv1
		command tmux new-window -d -c ~ -t srv: -n srv2
		command tmux new-session -d -c ~/dev/icub3d-addon -s wow -n wow
	end
	command tmux attach -t home
end
