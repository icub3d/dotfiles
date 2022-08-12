#!/usr/bin/fish
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
	
sudo apt update

sudo apt install syncthing
