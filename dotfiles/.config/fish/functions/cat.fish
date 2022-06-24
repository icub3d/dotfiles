function cat
    if command -vq bat
        command bat $argv
    else
        command cat $argv
    end 
end
