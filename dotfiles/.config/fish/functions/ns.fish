function ns
	command tmux new-session -d -c $argv[2] -s $argv[1]
end
