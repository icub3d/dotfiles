#!/usr/bin/fish

function go-binaries
	env GO111MODULE=on go install github.com/mikefarah/yq@v1
	env GO111MODULE=on go install github.com/go-delve/delve/cmd/dlv@latest
	env GO111MODULE=on go install golang.org/x/tools/gopls@latest
	go install github.com/nsf/gocode@latest
	go install github.com/rogpeppe/godef@latest
	go install golang.org/x/tools/cmd/godoc@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go get -u github.com/cweill/gotests/...
	go install github.com/prasmussen/gdrive@latest
end
