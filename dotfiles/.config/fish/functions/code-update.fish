#!/usr/bin/env fish

function code-update
	pushd ~/.cache/paru/clone/visual-studio-code-insiders-bin/
	makepkg -fsri
	popd
end
