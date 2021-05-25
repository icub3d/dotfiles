#!/usr/bin/fish

if test ! -L /snap
	sudo ln -s /var/lib/snapd/snap /snap
end

sudo snap install microk8s --classic

sudo usermod -aG microk8s jmarsh

sudo systemctl enable --now snapd.socket
