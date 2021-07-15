#!/usr/bin/fish

function image-help
	pushd $argv[1]
	set WINDOWID (wmctrl -l | grep (xdotool getwindowfocus getwindowname | awk '{print $1;}'))
	set files (/usr/bin/ls)
	for file in $files
		nomacs $file >/dev/null 2>/dev/null &
		set PID (jobs -lp | tail -n 1)
		sleep 2
		wmctrl -ia $WINDOWID
		read -l -P "new name ($file): " name
		if test -n "$name"
			mv $file $name.pdf
		end
		kill -9 $PID
	end
	popd
	open $argv[1]
end
