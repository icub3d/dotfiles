function ls
    if command -vq exa
        command exa $argv
    else
        command ls $argv
    end 
end
