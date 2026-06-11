$env.PATH = ($env.PATH | append [
    "/opt/homebrew/bin"
    "/Applications/google-cloud-sdk/bin"
    ($env.HOME | path join ".rd/bin")
])

alias sed = gsed
alias base64 = gbase64
