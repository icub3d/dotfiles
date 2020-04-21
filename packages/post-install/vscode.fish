#!/usr/bin/fish

set EXTENSIONS \
	"bungcip.better-toml" \
	"christian-kohler.path-intellisense" \
	"CoenraadS.bracket-pair-colorizer-2" \
	"dbaeumer.vscode-eslint" \
	"eamodio.gitlens" \
	"esbenp.prettier-vscode" \
	"hoovercj.haskell-linter" \
	"jcanero.hoogle-vscode" \
	"jock.svg" \
	"justusadam.language-haskell" \
	"mattn.Lisp" \
	"mauve.terraform" \
	"MaxGabriel.brittany" \
	"mkxml.vscode-filesize" \
	"monokai.theme-monokai-pro-vscode" \
	"ms-azuretools.vscode-azureterraform" \
	"ms-azuretools.vscode-docker" \
	"ms-python.python" \
	"ms-vscode-remote.remote-ssh" \
	"ms-vscode-remote.remote-ssh-edit" \
	"ms-vscode.azure-account" \
	"ms-vscode.cpptools" \
	"ms-vscode.Go" \
	"ms-vscode.vscode-typescript-tslint-plugin" \
	"msjsdiag.debugger-for-chrome" \
	"msjsdiag.vscode-react-native" \
	"naumovs.color-highlight" \
	"ritwickdey.LiveServer" \
	"rust-lang.rust" \
	"skyapps.fish-vscode" \
	"stkb.rewrap" \
	"streetsidesoftware.code-spell-checker" \
	"TabNine.tabnine-vscode" \
	"tuttieee.emacs-mcx" \
	"UCL.haskelly" 

for ext in $EXTENSIONS
	code --force --install-extension $ext
end
