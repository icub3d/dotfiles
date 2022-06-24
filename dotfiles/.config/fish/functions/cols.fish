function cols
	set columns (string split , $argv[1])
	for c in (seq (count $columns))
		set columns[$c] "\$$columns[$c]"
	end
	set columns (string join , $columns)

	command awk $argv[2..-1] "{print $columns}" 
end
