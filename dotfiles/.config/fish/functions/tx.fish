function tx
	set -x SIMPLE_PROMPT true

	command tmux new-session -d -c ~/dev/dotfiles -s dot -n dot
	command tmux new-window -d -c ~/dev/dotfiles/dotfiles/.config/emacs -t dot:1 -n "emacs"
	command tmux new-window -d -c ~/dev/dotfile/dotfiles/.config/emacs -t dot:2 -n "emacs-daemon"
	command tmux send-keys -t dot:2 "emacs --fg-daemon" C-m

	command tmux new-session -d -c ~ -s home -n "home"
	command tmux new-window -d -c ~/dev -t home:1 -n "dev"

	if test "$ATWORK" = "true"
		command tmux new-session -d -c ~/dev/oti-azure -s oti -n "e"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:1 -n "run"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:2 -n "fish"
	end
	
	command tmux attach -t home
end
