function ls
    if command -vq exa
        command exa --icons $argv
	else if command -vq logo-ls
        command logo-ls $argv
    else
        command ls $argv
    end 
end
