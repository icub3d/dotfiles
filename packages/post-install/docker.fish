#!/usr/bin/fish

add_group docker
add_service docker

# Ubuntu/WSL doesn't nee this.
if test "$DISTO" != "Ubuntu"
	set LATEST (github_latest docker docker-credential-helpers)
	set VERSION ""
	if command -vq docker-credential-secretservice
		set VERSION (docker-credential-secretservice version)
	end

	if test "$LATEST" != "$VERSION" 
		http -F "https://github.com/docker/docker-credential-helpers/releases/download/$LATEST/docker-credential-secretservice-$LATEST-amd64.tar.gz" > tmp.tar.gz
		tar -xzf tmp.tar.gz
		chmod a+x docker-credential-secretservice
		mv docker-credential-secretservice ~/bin
		rm tmp.tar.gz
	end

	if not test -f $HOME/.config/docker.json
		echo '{"credsStore": "secretservice"}' >$HOME/.config/docker.json
	end
end
