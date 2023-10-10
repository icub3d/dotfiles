function update-cli-tools
	mkdir -p $HOME/bin $HOME/.config/cli-tools
	set ARCH (uname -m)

	# First, let's check to see if we have a different sha.
	curl -s https://files.marsh.gg/cli-tools.$ARCH.zip.sha512 | cols 1 >/tmp/cli-tools.sha512
	if test -f $HOME/.config/cli-tools/sha512
		if test (cat $HOME/.config/cli-tools/sha512) = (cat /tmp/cli-tools.sha512)
			echo "cli-tools is up to date"
			return
		end
	end

	# Othwerise, let's download the new version.
	mv /tmp/cli-tools.sha512 $HOME/.config/cli-tools/sha512
	curl -s https://files.marsh.gg/cli-tools.$ARCH.zip >/tmp/cli-tools.zip
	pushd $HOME/bin
	unzip -q -o /tmp/cli-tools.zip
	popd
	rm /tmp/cli-tools.zip
end
