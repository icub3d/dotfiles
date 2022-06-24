function emacs-react
	pushd node_modules/react-scripts/config/
	patch < ~/dev/dotfiles/webpackDevServer.config.js.patch
	popd
	echo "FAST_REFRESH=false" >>.env
end
