function tx
	set -x SIMPLE_PROMPT true

	command tmux new-session -d -c ~/dev/dotfiles -s dot -n dot
	command tmux new-window -d -c ~/dev/dotfiles/nvim -t dot:1 -n "nvim"

	command tmux new-session -d -c ~ -s home -n "home"
	command tmux new-window -d -c ~/dev -t home:1 -n "dev"

	if test "$ATWORK" = "true"
		command tmux new-session -d -c ~/dev/oti-azure -s oti -n "code"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:1 -n "fish"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:2 -n "run"
	else
	  set NOTES_DIR "$HOME/Documents/notes"
	  command tmux new-session -d -c "$NOTES_DIR" -s notes -n "notes"
		command tmux new-session -d -c ~ -s srv -n srv2
		command tmux new-window -d -c ~ -t srv:1 -n pihole
		command tmux new-window -d -c ~ -t srv:2 -n k8s
		command tmux split-window -d -c ~ -t srv:2 -h
		command tmux split-window -d -c ~ -t srv:2 -h
		command tmux split-window -d -c ~ -t srv:2 -h
    command tmux select-layout -t srv:2 even-horizontal
	end
	
	command tmux attach -t home
end
