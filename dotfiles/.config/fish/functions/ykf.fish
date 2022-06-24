function ykf
	gpgconf --reload gpg-agent
	gpgconf --kill scdaemon
	gpg-connect-agent reloadagent /bye
	sudo systemctl restart pcscd
end
