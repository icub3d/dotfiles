# Helper function that adds the path if it exists.
def add_path_if_exists [path] {
  if ($path | path exists) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend $path)
  }
}

# standard variables
$env.DISTRO = (lsb_release -is)
$env.HOSTNAME = (hostname)
$env.EDITOR = "nvim"

# standard paths
add_path_if_exists "/usr/local/bin"
add_path_if_exists ($nu.home-path + "/bin")
add_path_if_exists ($nu.home-path + "/.local/bin")

# bat
$env.BAT_THEME = "Monokai Extended"

# NPM
$env.NPM_PACKAGES = $nu.home-path + "/.npm-packages"
mkdir $env.NPM_PACKAGES + "/bin"
add_path_if_exists ($env.NPM_PACKAGES + "/bin")

# Python
$env.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"

# Go
add_path_if_exists "/usr/lib/go/bin",
add_path_if_exists "/usr/local/go/bin",
add_path_if_exists ($nu.home-path + "/go/bin")

# Rust
add_path_if_exists "/usr/local/cargo/bin",
add_path_if_exists ($nu.home-path + "/.cargo/bin")

# Yubikey
$env.GPG_TTY = (tty)
$env.SSH_AUTH_SOCK = "/run/user/" + (id -u) + "/gnupg/S.gpg-agent.ssh"
gpg-connect-agent updatestartuptty /bye out+err> /dev/null

# Prompt
$env.PROMPT_COMMAND = {|| printf '\033]7;file://%s%s\033\\' $env.HOSTNAME $env.PWD }
$env.PROMPT_INDICATOR = {|| "λ " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
