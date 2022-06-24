function hexdump
    if command -vq hx
        command hx $argv
    else
        command hexdump $argv
    end 
end
