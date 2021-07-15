function k
	if test "$argv[1]" = "gc"
		set argv config get-contexts
	else if test "$argv[1]" = "uc"
		set argv config use-context $argv[2]
	else if test "$argv[1]" = "ga"
		set argv get all $argv[2..-1]
	end
	echo kubectl $argv
	command kubectl $argv
end
