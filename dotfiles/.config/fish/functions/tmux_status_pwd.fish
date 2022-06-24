function tmux_status_pwd
	pushd (tmux display-message -p -F "#{pane_current_path}")
	echo (prompt_pwd)
end
