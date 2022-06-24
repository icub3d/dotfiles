function fish_prompt_print
	set -l last_status $status
    set -l normal (set_color normal)

	set -l color_cwd
    set -l prefix
    set -l suffix
    switch "$USER"
        case root toor
            if set -q fish_color_cwd_root
                set color_cwd $fish_color_cwd_root
            else
                set color_cwd $fish_color_cwd
            end
            set suffix '#'
        case '*'
            set color_cwd $fish_color_cwd
            set suffix '>'
    end

	tmux_status_tracker_save
	
	echo
	if not set -q SIMPLE_PROMPT
		set git (__fish_git_prompt | sed 's#[\)\|\(]##g')
		echo -s (set_color yellow) "$USER" $normal @ (set_color purple) (prompt_hostname) $normal ' ' (set_color $color_cwd) (prompt_pwd) $normal $git $normal
	end

    echo -n -s (set_color green) λ $normal " "
end
