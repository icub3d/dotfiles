#!/usr/bin/env fish

# Install Bitwarden CLI
mkdir -p ~/bin
wget -O ~/bin/bw 'https://vault.bitwarden.com/download/?app=cli&platform=linux'
chmod +x ~/bin/bw
