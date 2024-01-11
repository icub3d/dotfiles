function wezterm-switch-workspace
	trap 'wezterm-set-user-var WORKSPACE_CHANGED ""' EXIT
	wezterm-set-user-var WORKSPACE_CHANGED (fzf -1 --reverse --border=rounded --prompt 'workspace> ')
end
