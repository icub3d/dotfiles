function emacs
    if pgrep -a emacs | rg 'fg-daemon' >/dev/null
        command env TERM=xterm-24bit $EMACSCLIENTBIN -nw $argv
    else
        command env TERM=xterm-24bit $EMACSBIN -nw $argv
    end
end
