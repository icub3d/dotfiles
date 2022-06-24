function add_user_service
	systemctl --user --now enable $argv
end