#!/usr/bin/fish

function scan-help
	pushd $argv[1]
	set files (/usr/bin/ls)
	for file in $files
		open $file >/dev/null 2>/dev/null &
		read -l -P "new name ($file): " name
		if test -n "$name"
			mv $file $name.pdf
		end
	end
	popd
	open $argv[1]
end
