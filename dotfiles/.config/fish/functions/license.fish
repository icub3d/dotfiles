function license
    if command -vq licensor
        command bat $argv
    else
        command license $argv
    end 
end
