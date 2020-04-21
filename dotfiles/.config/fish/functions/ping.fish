function ping
    if command -vq prettyping
        command prettyping $argv
    else
        command ping $argv
    end 
end