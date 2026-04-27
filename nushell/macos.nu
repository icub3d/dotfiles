$env.PATH = ($env.PATH | append [
    "/opt/homebrew/bin"
    "/opt/podman/bin"
    "/Applications/google-cloud-sdk/bin"
    ($nu.home-dir | path join ".rd/bin")
])

alias sed = gsed
alias base64 = gbase64
