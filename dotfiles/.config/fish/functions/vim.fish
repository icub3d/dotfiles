#/usr/bin/fish
function vim
	if command -qv nvim
		command nvim $argv
	else
		command vim $argv
	end
end
