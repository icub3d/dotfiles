function find
    if command -vq fd
        command fd $argv
    else
        command find $argv
    end
end
