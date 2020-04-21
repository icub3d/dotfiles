source 'dotfiles.fish'

function update
	dotfiles

	pushd ~/dev/dotfiles

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
