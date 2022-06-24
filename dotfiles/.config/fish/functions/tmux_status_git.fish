function tmux_status_git
	echo (tmux-status-tracker get --path (tmux display-message -p -F "#{pane_current_path}"))
end
