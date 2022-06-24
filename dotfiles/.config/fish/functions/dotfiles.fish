function dotfiles
	pushd ~/dev/dotfiles

	mkdir -p ~/.config
	if ! test -L ~/.config/nvim
		ln -s $PWD/nvim ~/.config
	end

	# create directories for dotfiles
	mkdir -p (/usr/bin/find dotfiles -type f | /usr/bin/sed "s#dotfiles/#$HOME/#g" | xargs -n1 dirname | sort | uniq)
	chmod 700 $HOME/.ssh $HOME/.gnupg

	set READLINK_CMD readlink
	if test (uname -s) = "Darwin"
		set READLINK_CMD greadlink
	end

	# create the symlinks
	for DOTFILE in (/usr/bin/find dotfiles -type f | /usr/bin/sed 's#dotfiles/##g')
		# Skip if we already have the one we want.
		if test -L "$HOME/$DOTFILE" -a ($READLINK_CMD -f "$HOME/$DOTFILE") = "$PWD/dotfiles/$DOTFILE"
			continue
		end
			
		if test -L "$HOME/$DOTFILE" # unlink non-dotfile links
			unlink "$HOME/$DOTFILE"
		else if test -f "$HOME/$DOTFILE" # make a backup of others
			mv "$HOME/$DOTFILE" "$HOME/$DOTFILE.backup"
		end
		ln -s "$PWD/dotfiles/$DOTFILE" "$HOME/$DOTFILE"
	end

	if test  "$XDG_SESSION_TYPE" != "wayland"
		unlink $HOME/.config/environment.d/wayland.conf
	end

	# Make sure we have the latest from fish
	source $HOME/.config/fish/config.fish

	popd
end
