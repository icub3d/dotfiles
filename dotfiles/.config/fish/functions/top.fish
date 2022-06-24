function top
	if command -vq bpytop
		command bpytop
    else
        command top $argv
    end 
end
