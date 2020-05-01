function dotfiles
	pushd ~/dev/dotfiles
	
	# create directories for dotfiles
	mkdir -p (/usr/bin/find dotfiles -type f | /usr/bin/sed -e "s#dotfiles/#$HOME/#g" | xargs -n1 dirname | sort | uniq)
	chmod 700 $HOME/.ssh $HOME/.gnupg

	# create the symlinks
	for DOTFILE in (/usr/bin/find dotfiles -type f | /usr/bin/sed -e 's#dotfiles/##g')
		# Skip if we already have the one we want.
		if test -L "$HOME/$DOTFILE" -a (readlink -f "$HOME/$DOTFILE") = "$PWD/dotfiles/$DOTFILE"
			continue
		end
			
		if test -L "$HOME/$DOTFILE" # unlink non-dotfile links
			unlink "$HOME/$DOTFILE"
		else if test -f "$HOME/$DOTFILE" # make a backup of others
			mv "$HOME/$DOTFILE" "$HOME/$DOTFILE.backup"
		end
		ln -s "$PWD/dotfiles/$DOTFILE" "$HOME/$DOTFILE"
	end

	# Make sure we have the latest from fish
	source $HOME/.config/fish/config.fish

	popd
end
