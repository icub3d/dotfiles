function objdump
    if command -vq bingrep
        command bingrep $argv
    else
        command objdump $argv
    end 
end
