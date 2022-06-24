function fix-sleep
    dbus-send --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval "string:global.reexec_self()"
    sudo systemctl restart ckb-next-daemon
    killall ckb-next
    nohup /usr/local/bin/ckb-next >/dev/null 2>/dev/null &
end
