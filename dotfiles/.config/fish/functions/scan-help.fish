#!/usr/bin/fish

function scan-help
	pushd $argv[1]
	set files (/usr/bin/ls)
	for file in $files
		google-chrome-stable $file >/dev/null 2>/dev/null &
		read -l -P "new name ($file): " name
		if test -n "$name"
			mv $file $name.pdf
		end
	end
	for file in (/usr/bin/ls)
		gdrive upload --parent 1e4LApZXcXz3FamcLofLOmW9Ixnd-bAlU $file
	end
	popd
	nautilus $argv[1] &
	google-chrome-stable "https://drive.google.com/drive/u/0/folders/1e4LApZXcXz3FamcLofLOmW9Ixnd-bAlU" &
end
