#!/usr/bin/fish

if command -vq npm
	set MANS ""
	if command -vq manpath
		set MANS (manpath 2>/dev/null)
	end

	set -x NPM_PACKAGES $HOME/.npm-packages
	mkdir -p $NPM_PACKAGES/bin
	set -x PATH $NPM_PACKAGES/bin $PATH 
	set -e MANPATH
	set -x MANPATH $NPM_PACKAGES/share/man:$MANS
end
