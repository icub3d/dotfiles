function less
    if command -vq bat
        command bat $argv
    else
        command less $argv
    end 
end
