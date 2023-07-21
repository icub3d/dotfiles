function tmux_status_tracker_save
	git rev-parse 2>/dev/null >/dev/null
	if test $status -eq 0
		set GBRANCH (git rev-parse --abbrev-ref HEAD)
		set GSTATUS (git status --porcelain | cut -b 1,2 | sed 's/ /_/g' | sort | uniq -c | sort -k 2 | sed -e 's/^ *//g' | sed -z -e 's/\n/|/g' | sed -e 's/|$//g')
		tmux-status-tracker put --path (git rev-parse --show-toplevel) --branch $GBRANCH --git-status "$GSTATUS"
	end
end
