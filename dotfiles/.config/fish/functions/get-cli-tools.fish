function get-cli-tools
	mkdir -p ~/bin/
	http -F https://github.com/marshians/cli-tools/releases/download/master/cli-tools.tar.gz | \
		tar --strip-components=1 -C ~/bin -zx cli-tools-(string lower (uname -s))
end
