function update
	pushd ~/dev/dotfiles
	
	# create directories for dotfiles
	mkdir -p (/usr/bin/find dotfiles -type f | /usr/bin/sed -e "s#dotfiles/#$HOME/#g" | xargs -n1 dirname | sort | uniq)
	chmod 700 $HOME/.ssh $HOME/.gnupg

	# create the symlinks
	for DOTFILE in (/usr/bin/find dotfiles -type f | /usr/bin/sed -e 's#dotfiles/##g')
		if test -L "$HOME/$DOTFILE" -a (readlink -f "$HOME/$DOTFILE") != "$PWD/dotfiles/$DOTFILE"
			echo "old link found for $HOME/$DOTFILE, removing"
			unlink "$HOME/$DOTFILE"
		else if test -f "$HOME/$DOTFILE"
			mv "$HOME/$DOTFILE" "$HOME/$DOTFILE.backup"
		end
		ln -s "$PWD/dotfiles/$DOTFILE" "$HOME/$DOTFILE"
	end

	# Make sure we have the latest from fish
	source $HOME/.config/fish/config.fish

	# Pacman/Makepkg configurations
	sudo sed -i -e 's/#Color/Color/g' /etc/pacman.conf
	sudo sed -i -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'(nproc)'"/g' /etc/makepkg.conf

	if not grep marshians-aur /etc/pacman.conf >/dev/null ^/dev/null 
		echo -e "[marshians-aur]
		SigLevel = Optional TrustAll
		Server = https://arch.marsh.gg
		" | sudo tee -a /etc/pacman.conf >/dev/null
	end

	# Figure out which groups we are going to install.
	set SELECTED ""
	if test -f .selected_packages
		set SELECTED (cat .selected_packages)
	else
		set FULL_LIST (ls packages/pacman/ | sort | uniq)
		read -P "which packages? ($FULL_LIST) " SELECTED
		if test "$SELECTED" = ""
			set SELECTED $FULL_LIST
		end
		echo $SELECTED >.selected_packages
	end
	set SELECTED (string split ' ' -- $SELECTED)

	# Install any packages we need.
	set PACKAGES (begin; pushd packages/pacman; cat $SELECTED ^/dev/null; popd; end | sort | uniq)
	sudo pacman -Syu --needed --noconfirm $PACKAGES

	# Make sure we have the latest from fish
	source $HOME/.config/fish/config.fish

	for i in $SELECTED
		if test -f "packages/post-install/$i.fish"
			. packages/post-install/$i.fish
		end
	end

	for i in (ls packages/post-install)
		set NAME (echo $i | sed -e 's/.fish//g')
		if contains $NAME $PACKAGES
			. ./packages/post-install/$i
		end
	end

	# Make sure we have the latest from fish
	echo "you may want to resource the config"
	echo source $HOME/.config/fish/config.fish

	popd
end
