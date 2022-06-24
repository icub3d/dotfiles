function get-marshian-images
    command mkdir -p ~/Pictures
    for file in marshians-text-background-2k.png marshians-text-background-3k.png marshians-text-background-4k.png marshians-text-background-phone.png gopherizeme.png
        if test ! -f "$HOME/Pictures/$file"
            command http "https://images.themarshians.com/api/media/$file" > "$HOME/Pictures/$file"
        end
    end
end
