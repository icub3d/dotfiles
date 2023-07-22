function ns
	# Try some magic to find the directory if we aren't given one.
	if test "$argv[2]" = ""
		# First see if we can find a directory with the same name in dev.
		set dir (fd -t d $argv[1] ~/dev)
		if test "$dir" = ""
			# If not, just use the current directory.
			set dir (pwd)
		end
		set argv $argv[1] $dir
	end
	
	command tmux new-session -d -c $argv[2] -s $argv[1] -n e
	command tmux send-keys -t $argv[1]:0 "emacs -nw ." C-m
	command tmux new-window -d -t $argv[1] -n sh -c $argv[2]
end
