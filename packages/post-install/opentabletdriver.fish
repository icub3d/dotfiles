#/usr/bin/env fish

# add blacklist
if not grep -q "blacklist hid_uclogic" /etc/modprobe.d/blacklist.conf
	echo "blacklist hid_uclogic" | sudo tee -a /etc/modprobe.d/blacklist.conf
end
if not grep -q "blacklist wacom" /etc/modprobe.d/blacklist.conf
	echo "blacklist wacom" | sudo tee -a /etc/modprobe.d/blacklist.conf
end


# remove old drivers
sudo rmmod hid_uclogic 2>/dev/null
sudo rmmod wacom 2>/dev/null

# setup systemctl
systemctl --user enable --now opentabletdriver.service
