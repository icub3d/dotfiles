function tx
	set -x SIMPLE_PROMPT true

	command tmux new-session -d -c ~/dev/dotfiles -s dot -n dot
	command tmux new-window -d -c ~/dev/dotfiles/nvim -t dot:1 -n "nvim"

	command tmux new-session -d -c ~ -s home -n "home"
	command tmux new-window -d -c ~/dev -t home:1 -n "dev"

	# our notes
	set NOTES_DIR "$HOME/Documents/notes"
	command tmux new-session -d -c "$NOTES_DIR" -s notes -n "notes"
	
	if test "$ATWORK" = "true"
		command tmux new-session -d -c ~/dev/oti-azure -s oti -n "code"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:1 -n "fish"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:2 -n "run"
	else
		command tmux new-session -d -c ~ -s srv -n srv2
	end
	
	command tmux attach -t home
end
