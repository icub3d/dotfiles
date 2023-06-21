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
		set POD (kubectl get po | cols 1 | rg $argv[2] | head -1)
		set argv exec -it $POD -- /bin/bash
	else if test "$argv[1]" = "sh"
		set POD (kubectl get po | cols 1 | rg $argv[2] | head -1)
		set argv exec -it $POD -- /bin/sh
	else if test "$argv[1]" = "run"
		set POD (kubectl get po | cols 1 | rg $argv[2] | head -1)
		set argv exec $POD -- $argv[3..]
	else if test "$argv[1]" = "uc"
		set argv config use-context $argv[2]
	else if test "$argv[1]" = "ga"
		set argv get all $argv[2..-1]
	else if test "$argv[1]" = "oti"
		set argv config use-context "aks-oti-$argv[2]-eastus-001"
	else if test "$argv[1]" = "otvm"
		set argv config use-context "otvm-containerized-$argv[2]"
	end
	command kubectl $argv
end
