function tx
	set -x SIMPLE_PROMPT true

	command tmux new-session -d -c ~/dev/dotfiles -s • -n "🐟"

	command tmux new-session -d -c ~ -s 🏠 -n "🏠"
	command tmux new-window -d -c ~/dev -t 🏠:1 -n "🤖"
	command tmux new-window -d -c ~ -t 🏠:2 -n "🏢"

	if test "$ATWORK" = "true"
		command tmux new-session -d -c ~/dev/oti-azure -s oti -n "🐟"
		command tmux new-window -d -c ~/dev/oti-azure -t oti:1 -n "🏃"

		command tmux new-session -d -c ~/dev/edi-oti-otvm_containerized -s otvm -n "🐟"
		command tmux new-window -d -c ~/dev/edi-oti-otvm_containerized -t otvm:1 -n "🏃"
	end
	
	command tmux attach -t 🏠
end
