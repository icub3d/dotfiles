function wezterm-set-user-var
	printf "\033]1337;SetUserVar=%s=%s\007" $argv[1] (echo -n $argv[2] | base64)
	sleep 0.1
end

