$env.PATH = ($env.PATH | split row (char esep) | append '/opt/homebrew/bin')
$env.PATH = ($env.PATH | split row (char esep) | append '/opt/podman/bin')
$env.PATH = ($env.PATH | split row (char esep) | append '/Applications/google-cloud-sdk/bin')
$env.PATH = ($env.PATH | split row (char esep) | append ($nu.home-dir | path join ".rd/bin"))

alias sed = gsed 
alias base64 = gbase64
