def clean-paths [] {
    $in | where { |p| ($p | is-not-empty) and ($p | path exists) } | uniq
}

# Path conversions
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | clean-paths }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | clean-paths }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# standard variables
$env.DISTRO = if ($nu.os-info.name == "linux") { 
    open /etc/os-release | from csv --separator '=' --noheaders | where column0 == "ID" | get column1.0 
} else { $nu.os-info.name }

$env.ARCH = $nu.os-info.arch
$env.HOSTNAME = (sys host | get hostname)
$env.EDITOR = "nvim"
$env.ATWORK = (($env.HOME | path join ".atwork") | path exists)
$env.DOCKER_COMMAND = "podman"
$env.PODMAN_COMPOSE_WARNING_LOGS = "false"

# bat
$env.BAT_THEME = "ansi"
$env.PAGER = "bat -p"

# delta
$env.DELTA_FEATURES = "dark line-numbers decorations my-styles"

# NPM
$env.NPM_PACKAGES = ($nu.home-dir | path join ".npm-packages")
let npm_bin = ($env.NPM_PACKAGES | path join "bin")
if not ($npm_bin | path exists) { mkdir $npm_bin }

# Python
$env.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"

# Yubikey
$env.GPG_TTY = if ($nu.os-info.name == "linux") { (tty) } else { "" }
$env.SSH_AUTH_SOCK = if ($nu.os-info.name == "linux" ) { $"/run/user/(id -u)/gnupg/S.gpg-agent.ssh" } else { "" }
if ($nu.os-info.name == "linux") {
    do -i { gpg-connect-agent updatestartuptty /bye out+err> /dev/null }
}

# Generate fj completions
let fj_cache = ($nu.default-config-dir | path join "fj-completions.nu")
if (which fj | is-not-empty) {
    if not ($fj_cache | path exists) or ((ls $fj_cache | get 0.modified) < (ls (which fj | get 0.path) | get 0.modified)) {
        fj completion nushell 
        | str replace --all '[OWNER]/NAME' 'owner_name' 
        | save --force $fj_cache
    }
} else {
    if not ($fj_cache | path exists) {
        "export module completions {}" | save $fj_cache
    }
}

# Path setup
let custom_paths = [
    ($nu.home-dir | path join "bin"),
    ($nu.home-dir | path join ".local/bin"),
    ($nu.home-dir | path join ".cargo/bin"),
    ($nu.home-dir | path join ".npm-packages/bin"),
    ($nu.home-dir | path join "go/bin"),
    ($nu.home-dir | path join ".local/share/fnm"),
    "/usr/local/bin",
    "/usr/local/cargo/bin",
    "/usr/local/go/bin",
    "/usr/lib/go/bin",
]

$env.PATH = ($env.PATH | prepend $custom_paths | clean-paths)

# source os specific files and local stuff
source ($nu.default-config-dir | path join $"($nu.os-info.name).nu")
source ($nu.default-config-dir | path join "local.nu")
