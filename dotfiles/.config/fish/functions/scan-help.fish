#!/usr/bin/fish

function scan-help
	set 
	pushd $argv[1]
	set files (/usr/bin/ls)
	for file in $files
		open $file >/dev/null 2>/dev/null &
		read -l -P "new name ($file): " name
		if test -n "$name"
			mv $file $name.pdf
		end
		# This is the name of the scanned cabinet (not a secret)
		gdrive files upload --parent 1e4LApZXcXz3FamcLofLOmW9Ixnd-bAlU $name.pdf
	end
	popd
	open $argv[1]
end
