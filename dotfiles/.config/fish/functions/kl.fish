function kl
	command kubectl logs -c (string split - $argv | head -n -2 | string join -) -f po/$argv
end
