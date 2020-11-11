#!/usr/bin/fish

function go-binaries
	env GO111MODULE=on go get github.com/mikefarah/yq/v3
	go get -u github.com/go-delve/delve/cmd/dlv
	go get -u github.com/nsf/gocode
	go get -u github.com/rogpeppe/godef
	go get -u golang.org/x/tools/cmd/godoc
	go get -u golang.org/x/tools/cmd/goimports
	go get -u golang.org/x/tools/gopls
	go get -u github.com/cweill/gotests/...
end
