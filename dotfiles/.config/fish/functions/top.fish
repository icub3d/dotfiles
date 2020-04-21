function top
    if command -vq ytop
        command ytop $argv
    else
        command top $argv
    end 
end
