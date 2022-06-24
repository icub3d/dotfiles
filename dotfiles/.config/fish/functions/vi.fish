function vi
	if command -qv nvim
		command nvim $argv
	else if command -qv vim
		command vim $argv
	else
		command vi $argv
	end
end
