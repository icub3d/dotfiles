function add_group
	if not grep $argv /etc/group >/dev/null
		sudo groupadd $argv
	end
	sudo usermod -aG $argv $USER
end