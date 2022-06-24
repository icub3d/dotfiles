function ps
    if command -vq procs
        command procs $argv
    else
        command ps $argv
    end 
end
