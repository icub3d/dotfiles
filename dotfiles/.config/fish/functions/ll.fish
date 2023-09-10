function ll
    if command -vq logo-ls
        command logo-ls -alh $argv
    else if command -vq eza
        command eza -alh $argv
    else
        command ls -alh $argv
    end 
end
