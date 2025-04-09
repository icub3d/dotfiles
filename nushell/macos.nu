$env.PATH = ($env.PATH | split row (char esep) | append '/opt/homebrew/bin')
$env.PATH = ($env.PATH | split row (char esep) | append '/opt/podman/bin')
$env.PATH = ($env.PATH | split row (char esep) | append ($nu.home-path | path join ".rd/bin"))

alias sed = gsed 
alias base64 = gbase64

$env.NODE_OPTIONS = "--openssl-legacy-provider"
$env.GOPROXY = if ($env.ATWORK == "true") { "https://repo1.uhc.com/artifactory/golang-proxy/" } else { "" }
$env.GOSUMDB = if ($env.ATWORK == "true") { "sum.golang.org https://repo1.uhc.com/artifactory/golang-sum/" } else { "" }
$env.FNM_NODE_DIST_MIRROR = if ($env.ATWORK == "true") { "https://repo1.uhc.com/artifactory/nodejs-org" } else { "" }
