function tmux_status_branch
	echo tmux-status-tracker get --path (tmux display-message -p -F "#{pane_current_path}") >>~/status.log
	echo (tmux-status-tracker get --path (tmux display-message -p -F "#{pane_current_path}") | head -n 1)
end
