function top
    if command -vq ytop
        command ytop -p -s -c monokai $argv
    else
        command top $argv
    end 
end
