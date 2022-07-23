function update
	# Update dotfiles
	source "$HOME/.config/fish/functions/dotfiles.fish"
	dotfiles

	# Make sure we have the latest from fish
	pushd ~/dev/dotfiles
	source $HOME/.config/fish/config.fish

	# If we are using arch, we need to install yay.
	set PACKAGES_LOCATION apt
	if test "$DISTRO" != "Ubuntu"
		set PACKAGES_LOCATION pacman
		#install yay
		if not type -q yay
			mkdir -p ~/dev/
			git clone https://aur.archlinux.org/yay.git ~/dev/yay
			pushd ~/dev/yay
			makepkg -si --noconfirm
			popd
		end

		# Pacman/Makepkg configurations
		sudo /usr/bin/sed -i -e 's/#Color/Color/g' /etc/pacman.conf
		sudo /usr/bin/sed -i -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'(nproc)'"/g' /etc/makepkg.conf

		# multilib
    if grep gaming .selected_packages >/dev/null 2>/dev/null
		  if not grep '^\[multilib\]' /etc/pacman.conf >/dev/null 2>/dev/null 
		  	echo -e "[multilib]
		  	Include = /etc/pacman.d/mirrorlist
		  	" | sudo tee -a /etc/pacman.conf >/dev/null
		  end
    end
	end

	# Figure out which groups we are going to install.
	set SELECTED ""
	if test -f .selected_packages
		set SELECTED (cat .selected_packages)
	else
		set FULL_LIST (ls "packages/$PACKAGES_LOCATION/" | sort | uniq)
		read -P "which packages? ($FULL_LIST) " SELECTED
		if test "$SELECTED" = ""
			set SELECTED $FULL_LIST
		end
		echo $SELECTED >.selected_packages
	end
	set SELECTED (string split ' ' -- $SELECTED)

	# Install any packages we need.
	set PACKAGES (begin; pushd packages/$PACKAGES_LOCATION; cat $SELECTED 2>/dev/null; popd; end | sort | uniq)

	if test "$DISTRO" = "Ubuntu"
		yes | sudo apt update
		yes | sudo apt upgrade -y $PACKAGES
		yes | sudo apt autoremove
	else
		yes | yay -Syu --needed --noconfirm $PACKAGES
	end

	# Make sure we have the latest from fish
	source $HOME/.config/fish/config.fish

	for i in $SELECTED
		if test -f "packages/post-install/$i.fish"
			. packages/post-install/$i.fish
		end
	end

	for i in (/bin/ls packages/post-install)
		set NAME (echo $i | /usr/bin/sed 's/.fish//g')
		if contains $NAME $PACKAGES
			. ./packages/post-install/$i
		end
	end

	# Make sure we have the latest from fish
	echo "you may want to re-source the config"
	echo source $HOME/.config/fish/config.fish

	popd
end
