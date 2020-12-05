function top
    if command -vq ytop
        command ytop -f -p -s -c monokai $argv
    else
        command top $argv
    end 
end
