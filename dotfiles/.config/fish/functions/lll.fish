function lll
    if command -vq logo-ls
        command logo-ls -alhF $argv
    else if command -vq eza
        command eza -alhF $argv
    else
        command ls -alhF $argv
    end 
end
