function ls
    if command -vq logo-ls
        command logo-ls $argv
    else if command -vq exa
        command exa $argv
    else
        command ls $argv
    end 
end
