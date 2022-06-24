function tmux_status_host
	pushd (tmux display-message -p -F "#{pane_current_path}")
	echo $USER@(prompt_hostname)
end
