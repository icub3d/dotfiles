function grep
    if command -vq rg
        command rg $argv
    else
        command grep $argv
    end 
end
