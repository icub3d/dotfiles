function tx
	set -x SIMPLE_PROMPT true

	# start emacs daemon
	# em

	# our notes
	set NOTES_DIR "$HOME/Documents/notes"
	command tmux new-session -d -c "$NOTES_DIR" -s notes -n "notes"
	
	command tmux new-session -d -c ~ -s home -n "home"
	command tmux new-session -d -c ~/dev/dotfiles -s dot -n dot
	command tmux new-window -d -c ~/dev -t home:1 -n "dev"

	if test "$ATWORK" = "true"
		command tmux new-session -d -c ~/dev/oti-azure -s oti -n "code"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:1 -n "fish"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:2 -n "run"
	else
		command tmux new-window -d -c ~/dev -t home:1 -n "dev"
		command tmux new-session -d -c ~ -s srv -n srv2
	end
	
	command tmux attach -t home
end
