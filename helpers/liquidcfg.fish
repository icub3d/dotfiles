#!/usr/bin/fish

sudo cp ./99-liquidctl-custom.rules /etc/udev/rules.d
sudo cp liquidcfg.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable liquidcfg
