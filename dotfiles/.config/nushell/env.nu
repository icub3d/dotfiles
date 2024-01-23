# standard variables
$env.DISTRO = (lsb_release -is)
$env.ARCH = (uname -m)
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
$env.GPG_TTY = (tty)
$env.SSH_AUTH_SOCK = $"/run/user/(id -u)/gnupg/S.gpg-agent.ssh"
gpg-connect-agent updatestartuptty /bye out+err> /dev/null

# Prompt
$env.PROMPT_INDICATOR = $"(ansi green)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi green)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi blue)λ (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = $"(ansi yellow)λ (ansi reset)"
$env.PROMPT_COMMAND_RIGHT = {||}
$env.PROMPT_COMMAND = {|| 
  echo
  printf '\033]7;file://%s%s\033\\' $env.HOSTNAME $env.PWD
}
