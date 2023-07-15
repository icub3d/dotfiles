function ns
	if test "$argv[2]" = ""
		set argv $argv[1] (pwd)
	end
	command tmux new-session -d -c $argv[2] -s $argv[1] -n e
	command tmux send-keys -t $argv[1]:0 "emacs -nw ." C-m
	command tmux new-window -d -t $argv[1] -n sh -c $argv[2]
end
