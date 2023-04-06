function get-marshian-images
    command mkdir -p ~/Pictures
    for file in marshians-text-background-2k.png marshians-text-background-3k.png marshians-text-background-4k.png 
        if test ! -f "$HOME/Pictures/$file"
            command http "https://logo.marsh.gg/dist/marshians-text-green/$file" > "$HOME/Pictures/$file"
        end
    end
end
