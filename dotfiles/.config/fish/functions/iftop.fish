function iftop
    if command -vq bandwhich
        command bandwhich $argv
    else
        command iftop $argv
    end 
end
