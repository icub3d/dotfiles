#!/usr/bin/fish

add_group docker
add_service docker

# Ubuntu/WSL and armv7 doesn't need this.
if test "$DISTO" != "Ubuntu" -a (uname -m) = "x86_64"
	if not test -f $HOME/.config/docker.json
		echo '{"credsStore": "secretservice"}' >$HOME/.config/docker.json
	end
end
