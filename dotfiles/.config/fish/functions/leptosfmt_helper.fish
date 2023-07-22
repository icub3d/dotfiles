function leptosfmt_helper
	read -l -z src
	set fmt (printf "%s\n" $src | leptosfmt -m 80 -s -q 2>/dev/null)
	if test -n "$fmt"
		printf "%s\n" $fmt
	else
		printf "%s\n" $src
	end
end
