function fix_part
		set len (math (string length "$argv") % 4)
		if test "$len" = "2"
			echo "$argv=="
		else if test "$len" = "3"
			echo "$argv="
		else
			echo "$argv"
		end
end

function jwt-decode
	# get from line or stdin
	if test "$argv" = ""
		while read -l l
			set line $l
		end
	else
		set line "$argv"
	end

	# print out the first and second part (the last is the signature).
	set header (fix_part (echo "$line" | cut -d. -f1))
	set payload (fix_part (echo "$line" | cut -d. -f2))

	echo "$header" | tr '_-' '/+' | base64 -d -i 2>/dev/null | jq '.'
	echo "$payload" | tr '_-' '/+' | base64 -d -i 2>/dev/null | jq '.exp |= todateiso8601 | .iat |= todateiso8601 | .nbf |= todateiso8601'
end
