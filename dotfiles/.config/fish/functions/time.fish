function time
    if command -vq hyperfine
        command hyperfine $argv
    else
        command time $argv
    end 
end
