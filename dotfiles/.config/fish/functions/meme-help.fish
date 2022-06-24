function meme-help
	pushd $argv[1]
	set WINDOWID (wmctrl -l | grep (xdotool getwindowfocus getwindowname | awk '{print $1;}'))
	for file in (/usr/bin/ls)
		eog "$file" >/dev/null 2>/dev/null &
		set PID (jobs -lp | tail -n 1)
		sleep 2
		wmctrl -ia $WINDOWID
		read -l -P "new name ($file): " name
		if test -n "$name"
			cp "$file" $name
			rm "$file"
			mctl images put $name
		end
		kill -9 $PID
	end
	popd
end
