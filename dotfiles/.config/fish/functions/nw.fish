function nw
	if test -n "$argv[2]"
		set FOLDER $argv[2]
	else
		set FOLDER $HOME/dev/(fd --type d --strip-cwd-prefix --path-separator="/" --base-directory "$HOME/dev" --max-depth 3 | fzf --reverse --border=rounded --prompt="cwd> ")
	end

	if test -n "$argv[1]"
		set NAME $argv[1]
	else
		set NAME (basename $FOLDER)
		read -l -P "name [$NAME]> " NEW_NAME
		if test -n "$NEW_NAME"
			set NAME $NEW_NAME
		end
	end

	if test -n "$FOLDER" -a -n "$NAME"
		wezterm-set-user-var CREATE_WORKSPACE "$NAME|$FOLDER"
	end
end
