function update
	# Update dotfiles
	source "$HOME/.config/fish/functions/dotfiles.fish"
	dotfiles

	# Make sure we have the latest from fish
	pushd ~/dev/dotfiles
	source $HOME/.config/fish/config.fish

	# If we use other package managers in the futures, we
	# can change this.
	set PACKAGES_LOCATION apt

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
