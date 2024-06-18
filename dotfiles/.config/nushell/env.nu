# standard variables
$env.OS = $nu.os-info.name
$env.DISTRO = if ($env.OS == "linux") { (lsb_release -is) } else { "windows" }
$env.ARCH = $nu.os-info.arch
$env.HOSTNAME = (hostname)
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
$env.GPG_TTY = if ($env.OS == "linux") { (tty) } else { "" }
$env.SSH_AUTH_SOCK = $"/run/user/(id -u)/gnupg/S.gpg-agent.ssh"
if ($env.OS == "linux") {
  gpg-connect-agent updatestartuptty /bye out+err> /dev/null
}

# Prompt
$env.PROMPT_INDICATOR = $"(ansi green)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi green)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi blue)λ (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = $"(ansi yellow)|   (ansi reset)"
$env.PROMPT_COMMAND_RIGHT = {||}
$env.PROMPT_COMMAND = {|| 
  echo
  let file_info = $"7;file://($env.HOSTNAME)($env.PWD)"
  ansi --osc $file_info
}
