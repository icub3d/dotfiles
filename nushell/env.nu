# standard variables
$env.DISTRO = if ($nu.os-info.name == "linux") { (lsb_release -is) } else { $nu.os-info.name }
$env.ARCH = $nu.os-info.arch
$env.HOSTNAME = (sys host | get hostname)
$env.EDITOR = "nvim"
$env.ATWORK = if (($nu.home-path | path join ".atwork") | path exists) { "true" } else { "false" }

# bat
$env.BAT_THEME = "ansi"
$env.PAGER = "bat -p"

# delta
$env.DELTA_FEATURES = "dark side-by-side line-numbers decorations my-styles"

# NPM
$env.NPM_PACKAGES = ($nu.home-path | path join ".npm-packages")
mkdir ($env.NPM_PACKAGES | path join "bin")

# Python
$env.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"

# Yubikey
$env.GPG_TTY = if ($nu.os-info.name == "linux") { (tty) } else { "" }
$env.SSH_AUTH_SOCK = if ($nu.os-info.name == "linux" ) { $"/run/user/(id -u)/gnupg/S.gpg-agent.ssh" } else { "" }
if ($nu.os-info.name == "linux") {
  gpg-connect-agent updatestartuptty /bye out+err> /dev/null
}

# source os specific files
source ($nu.home-path | path join ".config" | path join "nushell" | path join $"($nu.os-info.name).nu")
