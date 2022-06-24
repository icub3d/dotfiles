function t
	if test "$argv[1]" = "ks"
		set argv[1] "kill-server"
	end
	tmux $argv
end
