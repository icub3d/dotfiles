function em
	# our emacs daemon
	set EMACS_CMD "/usr/bin/emacs"
	if test -f /usr/local/bin/emacs
		set EMACS_CMD "/usr/local/bin/emacs"
	end
	command tmux new-session -d -c ~ -s emacs -n emacs $FISHBIN -c "env TERM=xterm-24bit $EMACS_CMD --fg-daemon"
end
