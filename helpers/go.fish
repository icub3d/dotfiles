#!/usr/bin/fish

set VERSION 1.18.3

wget https://go.dev/dl/go{$VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go{$VERSION}.linux-amd64.tar.gz
rm go{$VERSION}.linux-amd64.tar.gz
