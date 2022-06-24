function ll
    if command -vq logo-ls
        command logo-ls -alh $argv
    else if command -vq exa
        command exa -alh $argv
    else
        command ls -alh $argv
    end 
end
