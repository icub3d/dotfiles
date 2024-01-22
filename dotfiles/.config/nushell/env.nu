# standard variables
$env.DISTRO = (lsb_release -is)
$env.HOSTNAME = (hostname)
$env.EDITOR = "nvim"
$env.ARCH = (uname -m)

# bat
$env.BAT_THEME = "ansi"
$env.PAGER = "bat -p"

# delta
$env.DELTA_FEATURES = "dark side-by-side line-numbers decorations my-styles"

# NPM
$env.NPM_PACKAGES = $nu.home-path + "/.npm-packages"
mkdir $env.NPM_PACKAGES + "/bin"

# Python
$env.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"

# Yubikey
$env.GPG_TTY = (tty)
$env.SSH_AUTH_SOCK = "/run/user/" + (id -u) + "/gnupg/S.gpg-agent.ssh"
gpg-connect-agent updatestartuptty /bye out+err> /dev/null

# Prompt
$env.PROMPT_COMMAND = {|| printf '\033]7;file://%s%s\033\\' $env.HOSTNAME $env.PWD }
$env.PROMPT_INDICATOR = {|| "λ " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
