function tx
	set -x SIMPLE_PROMPT true

	command tmux new-session -d -c ~/dev/dotfiles -s dot -n dot
	command tmux new-window -d -c ~/dev/dotfiles/nvim -t dot:1 -n "nvim"

	command tmux new-session -d -c ~ -s home -n "home"
	command tmux new-window -d -c ~/dev -t home:1 -n "dev"

	if test "$ATWORK" = "true"
		command tmux new-session -d -c ~/dev/oti-azure -s oti -n "e"
		command tmux send-keys -t oti:0 "v ." C-m
		command tmux new-window -d -c ~/dev/oti-azure -t oti:1 -n "run"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:2 -n "fish"
	end
	
	command tmux attach -t home
end
