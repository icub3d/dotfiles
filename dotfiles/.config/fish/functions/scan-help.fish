#!/usr/bin/fish

function scan-help
	pushd $argv[1]
	set WINDOWID (wmctrl -l | grep (xdotool getwindowfocus getwindowname | awk '{print $1;}'))
	set files (ls)
	for file in $files
		evince $file >/dev/null ^/dev/null &
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
end
