function du
    if command -vq dust
        command dust $argv
    else
        command du $argv
    end 
end
