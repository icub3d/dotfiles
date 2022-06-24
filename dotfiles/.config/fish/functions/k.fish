function k
	if test "$argv[1]" = "gc"
		set argv config get-contexts
	else if test "$argv[1]" = "l"
		set argv logs -f po/$argv[2]
	else if test "$argv[1]" = "gn"
		set argv get namespaces
	else if test "$argv[1]" = "ns"
		set argv config set-context --current --namespace=$argv[2]
	else if test "$argv[1]" = "bash"
		set argv exec -it $argv[2] -- /bin/bash
	else if test "$argv[1]" = "sh"
		set argv exec -it $argv[2] -- /bin/sh
	else if test "$argv[1]" = "run"
		set argv exec $argv[2] -- $argv[3..]
	else if test "$argv[1]" = "uc"
		set argv config use-context $argv[2]
	else if test "$argv[1]" = "ga"
		set argv get all $argv[2..-1]
	else if test "$argv[1]" = "oti"
		set argv config use-context "aks-oti-$argv[2]-eastus-001"
	end
	command kubectl $argv
end
