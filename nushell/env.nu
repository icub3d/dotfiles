# standard variables
$env.DISTRO = if ($nu.os-info.name == "linux") { (open /etc/os-release | find -r "^ID=" | str replace 'ID=' '') } else { $nu.os-info.name }
$env.ARCH = $nu.os-info.arch
$env.HOSTNAME = (sys host | get hostname)
$env.EDITOR = "nvim"
$env.ATWORK = if (($nu.home-dir | path join ".atwork") | path exists) { "true" } else { "false" }
$env.DOCKER_COMMAND = "podman"
$env.PODMAN_COMPOSE_WARNING_LOGS = "false"

# bat
$env.BAT_THEME = "ansi"
$env.PAGER = "bat -p"

# delta
$env.DELTA_FEATURES = "dark line-numbers decorations my-styles"

# NPM
$env.NPM_PACKAGES = ($nu.home-dir | path join ".npm-packages")
mkdir ($env.NPM_PACKAGES | path join "bin")

# Python
$env.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"

# Yubikey
$env.GPG_TTY = if ($nu.os-info.name == "linux") { (tty) } else { "" }
$env.SSH_AUTH_SOCK = if ($nu.os-info.name == "linux" ) { $"/run/user/(id -u)/gnupg/S.gpg-agent.ssh" } else { "" }
if ($nu.os-info.name == "linux") {
  gpg-connect-agent updatestartuptty /bye out+err> /dev/null
}

# Generate fj completions
let fj_cache = ($nu.default-config-dir | path join "fj-completions.nu")
if (which fj | is-not-empty) {
    fj completion nushell 
    | str replace --all '[OWNER]/NAME' 'owner_name' 
    | save --force $fj_cache
} else {
    # Ensure the file exists so config.nu can source it without error
    if not ($fj_cache | path exists) {
        "module completions {}" | save $fj_cache
    }
}

# source os specific files and local stuff
source ($nu.default-config-dir | path join $"($nu.os-info.name).nu")
source ($nu.default-config-dir | path join "local.nu")

