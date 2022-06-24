#!/usr/bin/env fish

. $HOME/dev/dotfiles/packages/post-install/base.fish
. $HOME/dev/dotfiles/packages/post-install/dev.fish

# install python and it's stuff
if not test -f /usr/bin/python3.10
	sudo add-apt-repository ppa:deadsnakes/ppa
	sudo apt install python3.10
	sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
	sudo apt install python3.10-distutils
	curl -sS https://bootstrap.pypa.io/get-pip.py  | python
end

# kubectl
if not test -f /usr/local/bin/kubectl
	set KV (curl -L -s https://dl.k8s.io/release/stable.txt)
	curl -LO "https://dl.k8s.io/$KV/bin/linux/amd64/kubectl"
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl
end

# github cli
set GHA (dpkg --print-architecture)
if not test -f /etc/apt/sources.list.d/github-cli.list
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$GHA signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt update
	sudo apt install gh
end

# nodejs
if not test -f /usr/bin/node
	curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
	sudo apt-get install -y nodejs
	. $HOME/dev/dotfiles/packages/post-install/npm.fish
end

# terraform
set REL  (lsb_release -cs)
if not grep 'hashicorp' /etc/apt/sources.list >/dev/null 
	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	sudo apt-add-repository "deb [arch=$GHA] https://apt.releases.hashicorp.com $REL main"
	sudo apt install terraform
end

# stern
if not test -f /usr/local/bin/stern
	wget -Ostern https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
	sudo install -o root -g root -m 0755 stern /usr/local/bin/stern
	rm stern
end

# k9s
if not test -f /home/jmarsh/.local/bin/k9s
	curl -sS https://webinstall.dev/k9s | bash
end

#  mongodb
if not test -f /etc/apt/sources.list.d/mongodb-org-5.0.list
	wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
	sudo apt-get update
	sudo apt-get install -y mongodb-org
end

