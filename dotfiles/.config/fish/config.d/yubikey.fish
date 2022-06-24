#/usr/bin/fish

if command -vq ykman
	set -x GPG_TTY (tty)
	set -x SSH_AUTH_SOCK "/run/user/"(id -u)"/gnupg/S.gpg-agent.ssh"
	gpg-connect-agent updatestartuptty /bye >/dev/null 2>/dev/null
end
