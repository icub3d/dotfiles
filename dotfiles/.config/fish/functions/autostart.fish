function autostart
	set NAME (basename $argv[1])
	echo "
[Desktop Entry]
Type=Application
Name=$NAME
Comment=$NAME
Exec=$argv[1]
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false
" > ~/.config/autostart/$NAME.desktop
end
