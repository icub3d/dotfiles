function lll
    if command -vq logo-ls
        command logo-ls -alhF $argv
    else if command -vq exa
        command exa -alhF $argv
    else
        command ls -alhF $argv
    end 
end
