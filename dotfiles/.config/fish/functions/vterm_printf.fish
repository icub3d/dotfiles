function vterm_printf
    printf "\e]%s\e\\" "$argv"
	# This doesn't appear to be necessary and seems to mess up the normal shell?
    # if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end 
    #     # tell tmux to pass the escape sequences through
    #     printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
    # else
    #     printf "\e]%s\e\\" "$argv"
    # end
end
