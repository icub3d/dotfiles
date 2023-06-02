function get-marshian-images
    command mkdir -p ~/Pictures
    for file in marshians-text-green-background-2k.png marshians-text-green-background-3k.png marshians-text-green-background-4k.png marshians-text-green-400.png
        if test ! -f "$HOME/Pictures/$file"
            command http "https://logo.marsh.gg/dist/marshians-text-green/$file" > "$HOME/Pictures/$file"
        end
    end
    for file in marshians-green-background-2k.png marshians-green-background-3k.png marshians-green-background-4k.png marshians-green-400.png
        if test ! -f "$HOME/Pictures/$file"
            command http "https://logo.marsh.gg/dist/marshians-green/$file" > "$HOME/Pictures/$file"
        end
    end
end
