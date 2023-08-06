function install-bitwarden-cli
	pushd /tmp
	wget -Obw.zip 'https://vault.bitwarden.com/download/?app=cli&platform=linux'
	unzip bw.zip
	chmod +x bw
	mv bw ~/bin/
	popd
end
