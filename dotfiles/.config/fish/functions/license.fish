function license
    if command -vq licensor
        command licensor $argv
    else
        command license $argv
    end 
end
