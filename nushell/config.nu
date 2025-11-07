# source our secret file if it exists.
const secrets_path = ($nu.default-config-dir | path join ".env.nu")
if ($secrets_path | path exists) {
  source $secrets_path
}

# Windows doesn't seem to like this.
if ($nu.os-info.name == "windows") {
  $env.config.shell_integration."osc133" = false
}

# A list of all of our custom paths.
let paths = [
  # bin paths
  "/usr/local/bin",
  ($nu.home-path | path join "bin"),
  ($nu.home-path | path join ".local/bin"),
  
  # rust
  "/usr/local/cargo/bin",
  ($nu.home-path | path join ".cargo/bin"),
  
  # npm
  ($nu.home-path | path join ".npm-packages/bin"),
  
  # go
  ($nu.home-path | path join "go/bin"),
  "/usr/local/go/bin",
  "/usr/lib/go/bin",

  # fnm
  ($nu.home-path | path join ".local/share/fnm"),
];

# Prompt
$env.PROMPT_INDICATOR = $"(ansi green)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi green)λ (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi blue)λ (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = $"(ansi yellow)|   (ansi reset)"
$env.PROMPT_COMMAND_RIGHT = {||}
$env.PROMPT_COMMAND = {||}

# Load the environment from the system profiles.
if ($nu.os-info.name == "linux") {
  bash -c $"[ -f /etc/profile ] && source /etc/profile; [ -f ($env.HOME)/.profile ] && source ($env.HOME)/.profile; env" | lines | parse "{n}={v}" | where { |x| (not ($x.n in $env)) or $x.v != ($env | get $x.n) } | where {|x| not ($x.n in ["_", "LAST_EXIT_CODE", "DIRS_POSITION"])} | transpose --header-row | into record | load-env
}

# Add our custom paths to the PATH variable and clean it up
$env.PATH = ($env.PATH | split row (char esep) | prepend $paths | uniq);

# fnm setup
if ((which fnm | length) > 0) {
  # Load fnm environment variables
  load-env (fnm env --shell bash | lines | str replace 'export ' '' | str replace -a '"' '' | split column "=" | rename name value | where name != "FNM_ARCH" | where name != "PATH" | reduce -f {} {|it, acc| ($acc | upsert $it.name $it.value )})
  
  # Add fnm's current node path to PATH (no /bin subdirectory needed)
  $env.PATH = ($env.PATH | prepend ($env.FNM_MULTISHELL_PATH | path join "bin"))
  $env.PATH = ($env.PATH | prepend $env.FNM_MULTISHELL_PATH)
}

# General config
$env.config = {
  show_banner: false,
  edit_mode: "vi",
  history: {
    max_size: 1_000_000,
    sync_on_enter: true,
    isolation: true,
    file_format: sqlite,
  }
  hooks: {
    pre_prompt: [
      {
        print " " 
        let file_info = $"7;file://($env.HOSTNAME)($env.PWD)"
        ansi --osc $file_info
      }
    ]
  },
  keybindings: [
    {
      name: "fzf_dir_cd",
      modifier: control,
      keycode: char_t,
      mode: [vi_insert, vi_normal],
      event: {
        send: ExecuteHostCommand,
        cmd: "let folder = (select-folder $env.PWD); if ($folder | is-empty) { } else { cd $folder }"
      }
    },
    {
      name: "fzf_dir_cd_dev_depth3",
      modifier: control,
      keycode: char_d,
      mode: [vi_insert, vi_normal],
      event: {
        send: ExecuteHostCommand,
        cmd: "let folder = (select-folder ($nu.home-path | path join dev) 3); if ($folder | is-empty) { } else { cd $folder }"
      }
    },
    {
      name: "fzf_dir_insert",
      modifier: alt,
      keycode: char_t,
      mode: [vi_insert, vi_normal],
      event: {
        send: ExecuteHostCommand,
        cmd: "let folder = (select-folder $env.PWD); if ($folder | is-empty) { } else { commandline edit -i $folder }"
      }
    },
    {
      name: "fzf_dir_insert_dev_depth3",
      modifier: alt,
      keycode: char_d,
      mode: [vi_insert, vi_normal],
      event: {
        send: ExecuteHostCommand,
        cmd: "let folder = (select-folder ($nu.home-path | path join dev) 3); if ($folder | is-empty) { } else { commandline edit -i $folder }"
      }
    },
    {
          name: paste_bash_as_nushell
    modifier: alt
    keycode: char_v
    mode: [emacs, vi_normal, vi_insert]
    event: {
        send: executehostcommand
        cmd: "
            let clipboard = (
                if ($nu.os-info.name == 'windows' or (('/proc/version' | path exists) and (open /proc/version | str contains \"microsoft\"))) {
                    powershell.exe -command Get-Clipboard | str trim
                } else if ($nu.os-info.name == 'macos') {
                    pbpaste | str trim
                } else {
                    # Try wl-paste first (Wayland), fallback to xclip (X11)
                    try {
                        wl-paste | str trim
                    } catch {
                        xclip -selection clipboard -o | str trim
                    }
                }
            )
            
            # Convert bash syntax to nushell
            let converted = ($clipboard
                | str replace --all --regex '\\\\$' ' '  # backslash at end
                | str replace --all --regex '\\\\\\r?\\n' ' '  # backslash+newline
                | str replace --all '&&' ';'                    # && to semicolon
                | str replace --all --regex '\\s+;\\s+' '; '   # clean up spacing around semicolons
            )
            
            commandline edit --replace $converted
        "
    }
    }
  ]
}

# aliases
alias bench = hyperfine
alias cat = bat
alias d = docker
alias dc = docker compose
alias du = dust
alias p = podman
alias pc = podman compose
alias diff = delta
alias g = git
alias gg = lazygit
alias grep = rg
alias h = hyprctl
alias hexdump = hx
alias iftop = bandwhich
alias img = wezterm imgcat
alias less = bat
alias m = make
alias mk = minikube
alias objdump = bingrep
alias ping = prettyping
alias pointer = highlight-pointer -c '#ff6188' -p '#a9dc76' -r 10
alias rg = rg --hidden --glob '!.git'
alias v = nvim
alias w = viddy

#########################################################
# functions
#########################################################

# A helper to print messages in a consistent style
def "print-info" [message: string] {
    print $"✅ ($message)"
}

# A helper to print error messages
def "print-error" [message: string] {
    print -e $"❌ ERROR: ($message)"
}

# Clear the terminal and scrollback so watch output starts from a clean buffer.
def "reset-terminal" [] {
    print -n "\u{001b}c"
    print -n "\u{001b}[3J\u{001b}[H\u{001b}[2J"
    print -n "\u{001b}[0m"
}

# Normalize and convert a debug-formatted Rust Duration string into a Nushell duration
def "parse-duration" [value: string] {
    $value
    | str trim
    | split row " "
    | where {|part| not ($part | str trim | is-empty) }
    | each {|part|
        let normalized = (
            if ($part | str ends-with "ms") {
                $part
            } else if ($part | str ends-with "µs") {
                $part
            } else if ($part | str ends-with "us") {
                $part | str replace --regex "us$" "µs"
            } else if ($part | str ends-with "ns") {
                $part
            } else if ($part | str ends-with "s") {
                $part | str replace --regex "s$" "sec"
            } else if ($part | str ends-with "m") {
                $part | str replace --regex "m$" "min"
            } else if ($part | str ends-with "h") {
                $part | str replace --regex "h$" "hr"
            } else if ($part | str ends-with "d") {
                $part | str replace --regex "d$" "day"
            } else if ($part | str ends-with "w") {
                $part | str replace --regex "w$" "wk"
            } else {
                $part
            }
        )

        try { $normalized | into duration } catch { 0ns }
    }
    | math sum
}

# Parse an ini file
def "parse ini" [path?: path] {
  let content = if ($path | is-empty) {
    let data = $in
    if ($data | describe | str contains "list<string>") {
      $data
    } else if ($data | describe | str contains "string") {
      $data | lines
    } else {
      $data | into string | lines
    }
  } else {
    open --raw $path | lines
  }

  $content
  | where $it != "" and not ($it | str starts-with "#")  # ignore blanks and comments
  | reduce -f {} {|line, acc|
      if $line =~ '^\[.*\]$' {
          let section = ($line | str replace -a -r '\[|\]' '')
          $acc | upsert $section {} | upsert current_section $section
      } else if $line =~ ':' {
          let parts = ($line | split column -n 2 -r '[:=]' | each {|x| $x | str trim})
          let key = ($parts | get 0.column1)
          let val = ($parts | get 0.column2)
          let section = ($acc.current_section | into string)
          mut out = ($acc | reject current_section)
          let current = (if ($out | get $section | is-empty) { {} } else { $out | get $section })
          $out | upsert $section ($current | upsert $key $val) | upsert current_section $section
      } else {
          $acc
      }
  }
  | reject current_section
}

def "lla" [path = "."] {
  ls -la $path
}

def "la" [path = "."] {
  ls -a $path
}

def "ll" [path = "."] {
  ls -l $path 
}

def "l" [path = "."] {
  ls $path
}

def missing-packages [] {
  let installed = (pacman -Q | lines | parse "{package} {version}" | get package)
  let selected_packages = (open ~/dev/dotfiles/.selected_packages | split words)
  let missing = $selected_packages | where { |p| not ($p in $installed) }
  let packages = $selected_packages | each {|p|
    let package_path = $"packages/pacman/($p)"
    open $package_path | lines
  } | flatten | where { |p| not ($p in $installed) }
}

def git-config-setup [] {
  # Append our includes in .gitconfig if they are not there.
  let includes = "\n\n#dotfiles-includes\n[include]\n  path = ~/.gitconfig.base\n  path = ~/.gitconfig.local\n"
  if (not ("~/.gitconfig" | path exists)) {
    $includes | save ~/.gitconfig
  } else if ((open ~/.gitconfig | lines | find "#dotfiles-includes" | length) < 1) {
      $includes | save -a ~/.gitconfig
  }
}

def update-system [] {
  dotfiles
  cd ~/dev/dotfiles
  let package_location = "pacman"

  git-config-setup

	# Pacman/Makepkg configurations
  sudo /usr/bin/sed -i -e 's/#Color/Color/g' /etc/pacman.conf
  sudo /usr/bin/sed -i -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'(nproc)'"/g' /etc/makepkg.conf
  sudo /usr/bin/sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

  # install rustup - paru needs it and dev will need it.
  if (not ("/usr/bin/rustup" | path exists)) {
    sudo pacman -S rustup --noconfirm
  }
  rustup toolchain add stable

  # check to see if paru is installed
  sudo pacman -Sy
  if (not ("/usr/bin/paru" | path exists)) {
    # install paru
    mkdir ~/dev/
    cd ~/dev/
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
  } else {
    cd ~/dev/paru
    git pull
    makepkg -si --noconfirm
  }


  # check to see if the .selected_packages file is there.
  cd ~/dev/dotfiles
  if (not (".selected_packages" | path exists)) {
    let full_list = (ls packages/pacman/ | each {|f| $f.name | str replace packages/pacman/ "" } | sort | uniq)
    echo $"($full_list)"
    let selected = input $"packages to install> "
    if ($selected != "") {
      $selected | save -f .selected_packages
    } else {
      echo "no packages selected"
      return
    }
  }
  let selected_packages = (open .selected_packages | str trim | split row " ")

  # add multilib if we have selected gaming.
  if ("gaming" in $selected_packages) {
    if ((open /etc/pacman.conf | lines | find -r '^\[multilib\]' | length) < 1) {
      echo "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | sudo tee -a /etc/pacman.conf out> /dev/null
    }
  }

  let installed = (pacman -Q | lines | parse "{package} {version}" | get package)
  let packages = $selected_packages | each {|p|
    let package_path = $"packages/pacman/($p)"
    open $package_path | lines
  } | flatten
  let needed = $packages | where { |p| not ($p in $installed) }

  echo $"missing packages: ($needed)"

  # install packages
  do -i {
    yes | paru -Syu --needed --noconfirm ...$needed
  }
  
  # run the post install scripts
  for package in $packages {
    let script_path = $"packages/post-install/($package).nu"
    if ($script_path | path exists) {
      do -i {
        nu -c $"source $nu.env-path; source $nu.config-path; source ($script_path)"
      }
    }
  }

  for package in $selected_packages {
    let script_path = $"packages/post-install/($package).nu"
    if ($script_path | path exists) {
      do -i {
        nu -c $"source $nu.env-path; source $nu.config-path; source ($script_path)"
      }
    }
  }

  echo "you may want to resource the config"
  echo "source $nu.env-path"
  echo "source $nu.config-path"
}

def dotfiles [] {
  cd ~/dev/dotfiles

  # neovim
  mkdir ~/.config
  if (not ("~/.config/nvim" | path exists)) {
    ln -s ~/dev/dotfiles/nvim ~/.config/nvim
  }

  # gnupg
  mkdir ~/.gnupg
  if (not ("~/.gnupg/gpg.conf" | path exists)) {
    cp helpers/gpg.conf ~/.gnupg/gpg.conf
    chmod 600 ~/.gnupg/gpg.conf
  }
  if (not ("~/.gnupg/gpg-agent.conf" | path exists)) {
    cp helpers/gpg-agent.conf ~/.gnupg/gpg-agent.conf
    chmod 600 ~/.gnupg/gpg-agent.conf
  }

  # make sure we have all the diretories we need
  ls -a ~/dev/dotfiles/dotfiles/** |
     get name |
     each {|f| str replace ($nu.home-path | path join "dev/dotfiles/dotfiles/") "" } |
     each {|f| ($nu.home-path | path join $f) } |
     each {|f| mkdir $f}
  mkdir ~/.ssh
  chmod 700 ~/.ssh
  chmod 700 ~/.gnupg

  # make symlinks for all the files
  let paths = ls -a ~/dev/dotfiles/dotfiles/**/* | 
    where {|p| $p.type == "file"} | 
    get name | 
    each {|n| $n | str replace ($nu.home-path | path join "dev/dotfiles/dotfiles/") ""} |
    each {|n|
      let $new_path = ($nu.home-path | path join $n)
      let $org_path = ($nu.home-path | path join "dev/dotfiles/dotfiles" | path join $n)
      if (not ($new_path | path exists)) {
        ln -s $org_path $new_path
      }
      $new_path
    }
}

def update-cli-tools [] {
  mkdir ($nu.home-path | path join "bin")
  mkdir ($nu.home-path | path join ".config/cli-tools")

  # check to see if we have a different sha512
  let sha512 = (http get $"https://files.marsh.gg/cli-tools.($env.ARCH).zip.sha512")
  let existing_path = ($nu.home-path | path join ".config/cli-tools/sha512")
  if ($existing_path | path exists) {
    let existing = (cat $existing_path)
    if ($existing == $sha512) {
      echo "cli-tools are up to date"
      return
    }
  }

  $sha512 | save -f $existing_path
  http get $"https://files.marsh.gg/cli-tools.($env.ARCH).zip" | save -f cli-tools.zip
  unzip -o cli-tools.zip -d ($nu.home-path | path join "bin") out> /dev/null
  rm cli-tools.zip
}

def strongbox [] {
  $env.gdk_scale = 2
  java -jar ~/dev/strongbox.jar
}

def smoke-test-ligatures [] {
  print "normal"
  print $"(ansi attr_bold)bold(ansi reset)"
  print $"(ansi attr_italic)italic(ansi reset)"
  print $"(ansi attr_bold)(ansi attr_italic)bold italic(ansi reset)"
  print $"(ansi attr_underline)underline(ansi reset)"
  print "== === !== >= <= =>"
  print "契         勒 鈴 "
}

def scan-help [path] {
  ls $path | each {|file|
    firefox-developer-edition $file.name
    let base = $file.name | path basename
    let name = input $"name ($base)> "
    let name = if ($name == "") {
      $file.name
    } else {
      $name 
    }
    let name = ($path | path join ([$name, '.pdf'] | str join))
    mv $file.name $name
    gdrive files upload --parent "1e4LApZXcXz3FamcLofLOmW9Ixnd-bAlU" $"($name)"
  }
}

def catppuccin [palette = "mocha"] {
  let colors = http get https://raw.githubusercontent.com/catppuccin/palette/refs/heads/main/palette.json | 
    get $palette | get colors | values | sort-by order -n;

  $colors | each {|color| 
    let display = { fg: '#000000', bg: $color.hex };
    let preview = $"(ansi --escape $display)        (ansi reset)";
    let rgb = $"rgb\(($color.rgb.r), ($color.rgb.g), ($color.rgb.b))";
    let h = ($color.hsl.h | into string --decimals 2);
    let s = ($color.hsl.s | into string --decimals 2);
    let l = ($color.hsl.l | into string --decimals 2);
    let hsl = $"hsl\(($h), ($s), ($l))";
    {"preview": $preview, "name": $color.name, "hex": $color.hex, "rgb": $rgb, "hsl": $hsl}
  }
}

def mirrors [] {
  http get 'https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4&use_mirror_status=on' |
    sed -e 's/^#Server/Server/' -e '/^#/d' |
    rankmirrors -n 5 - | 
    sudo tee /etc/pacman.d/mirrorlist
}

def "mctl files put" [...files] {
  for file in $files {
    scp $"($file)" srv2:/data/exports/k8s/files/
  }
}

def "mctl images put" [...images] {
  let mongo_uri = bw-get-token "mongo-bank-cloud-uri"
  for image in $images {
    let mime = (file -b --mime-type $image)
    scp $"($image)" srv2:/data/exports/k8s/images/
    imagesctl -u $"($mongo_uri)" put $"($image)" $"($mime)" ($image | sed 's/[ .-]/,/g')
  }
}

def liquid [] {
	liquidctl initialize all
	liquidctl --serial 1805006373291a10 set fan1 speed 20 800 30 900 40 1000 50 1500 60 2000 --temperature-sensor 3
	liquidctl --serial 1805006373291a10 set fan2 speed 20 800 30 900 40 1000 50 1500 60 2000 --temperature-sensor 3
	liquidctl --serial 1805006373291a10 set led1 color fixed 00ff00
	liquidctl --serial 1805006373291a10 set led2 color fixed 00ff00
	liquidctl --serial 1305006473291217 set fan1 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan2 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan3 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan4 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan5 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan6 speed 20 800 30 1500 40 2000 50 2500 55 3500 60 4800 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set led1 color fixed 00ff00
	liquidctl --serial 1305006473291217 set led2 color fixed 00ff00
}

def decode-jwt-section [] {
  tr '_-' '/+' | base64 -i -d err> /dev/null | from json
}

def jwt [] {
  split row '.' |
  enumerate | each {|row|
    if ($row.index == 0) {
      $row.item | decode-jwt-section | items {|k, v| {"section": "header", "key": $k, "value": $v}}
    } else if ($row.index == 1) {
      $row.item | decode-jwt-section | items {|k, v| {"section": "payload", "key": $k, "value": $v}}
    } else {
      {"section": "signature", "key": "", "value": $row.item}
    }
  } | flatten
}

def journal [file] {
  let parent = 13ezgh0lonuj2y1yhne5_dfo7p0pfkoci
  let base = $file | path parse | get stem
  ffmpeg -i $file -vn -acodec copy $"($base).aac"
  whisper $"($base).aac" --model medium --language en
  ls $"($base)*" | each {|f|
    gdrive files upload --parent $parent $f
  }
}

def iommu [] {
  ls /sys/kernel/iommu_groups | get name | path basename | sort -n | each {|group|
    ls $"/sys/kernel/iommu_groups/($group)/devices" | get name | path basename | each {|device|
      {"group": $group, "device":$device, "info": (lspci -nns $device) }
    }
  } | flatten
}

def add-group [group] {
  sudo usermod -aG $group $env.USER
}

def add-service [service] {
  sudo systemctl --now enable $service
}

def add-user-service [service] {
  systemctl --user --now enable $service
}

def bw-get-token [name] {
  let login_check = do { bw login --check } | complete
  if ($login_check.exit_code != 0) {
    bw login
  }
  bw list items --search $name | from json | first | get login | get password
}

def allowance [] {
  let mongo_uri = bw-get-token "mongo-bank-cloud-uri"
  bankctl -u $mongo_uri -d bank add 808 james.marshian@gmail.com allowance
  bankctl -u $mongo_uri -d bank add 1500 william.marshian@gmail.com allowance
  bankctl -u $mongo_uri -d bank add 1308 samuel.marshian@gmail.com allowance
}

def my-ip [] {
  http get https://www.iplocate.io/api/lookup/
}

def github-latest [owner, repo] {
  let base = "https://api.github.com/repos/"
  let url = $"($base)($owner)/($repo)/releases/latest"
  http get $url
}

def download-arch-iso [] {
  let base = "https://mirrors.xtom.com/archlinux/iso/latest/"
  let sig = $"($base)archlinux-x86_64.iso.sig"
  let iso = $"($base)archlinux-x86_64.iso"

  # dowlnoad the iso
  http get $iso | save -f archlinux-x86_64.iso

  # download the signature
  http get $sig | save -f archlinux-x86_64.iso.sig

  # verify the signature
  let sig_check = do { gpg -q --keyserver-options auto-key-retrieve --verify archlinux-x86_64.iso.sig archlinux-x86_64.iso } | complete
  if ($sig_check.exit_code != 0) {
	echo "signature verification failed"
  }
}

def get-marshian-images [] {
  let base = "https://logo.marsh.gg/dist/"
  let images = [
	"marshians-text-green/marshians-text-green-background-3k.png",
	"marshians-green/marshians-green-background-3k.png",
  ];
  for image in $images {
	http get $"($base)($image)" | save -f ($nu.home-path | path join "Pictures" | path join ($image | path split | last))
  http get "https://img.marsh.gg/avatar.png" | save -f ($nu.home-path | path join "Pictures/avatar.png")
  }
}

def ykf [] {
  gpgconf --reload gpg-agent
  gpgconf --kill scdaemon
  gpg-connect-agent reloadagent /bye
  sudo systemctl restart pcscd
}

def select-folder [path, depth = 0] {
  let selected_path_rel = (
    (if $depth == 0 {
      fd --type d --strip-cwd-prefix --path-separator="/" --base-directory $path
    } else {
      fd --type d --strip-cwd-prefix --path-separator="/" --base-directory $path --max-depth $depth
    })
    | fzf --reverse --border=rounded --prompt "path> "
  )

  if ($selected_path_rel | is-empty) {
    return ""
  }

  let folder = ($path | path join $selected_path_rel)

  $folder
}

alias goto = cd (select-folder ($nu.home-path | path join dev))
alias gotol = cd (select-folder $env.PWD)

def nw [name = "", folder = ""] {
  let dev = $nu.home-path | path join "dev"
  let folder = if ($folder == "") {
    ($dev | path join (fd --type d --strip-cwd-prefix --path-separator="/" --base-directory $dev --max-depth 3 | fzf --reverse --border=rounded --prompt "path> "))
  } else {
    $folder
  }

  let name = if ($name == "") {
    let name = $folder | path basename
    let new_name = input $"name [($name)]> "
    if ($new_name == "") {
      $name
    } else {
      $new_name
    }
  } else {
    $name
  }

  if ("TMUX_PANE" in $env) {
    tmux new-session -d -c $folder -s $name -n "nv"
    tmux send-keys -t $"($name):0" "v . " C-m
    tmux new-window -d -c $folder -t $"($name):1" -n "nu"
  } else {
    let id = (wezterm cli spawn --new-window --workspace $name --cwd $folder "nu" "-l" | str trim)
    wezterm cli send-text --pane-id $id "wezterm cli set-tab-title nv\n"
    wezterm cli send-text --pane-id $id "v .\n"
    let id = (wezterm cli spawn --pane-id $id "nu" "-l" | str trim)
    wezterm cli send-text --pane-id $id "wezterm cli set-tab-title nu; clear\n"
  }
}

alias k = kubectl
def "k gc" [] {
  k config get-contexts
}

def "k l" [pod] {
  k logs -f po/$pod
}

def "k gn" [] {
  k get namespaces
}

def "k ns" [namespace] {
  k config set-context --current $"--namespace=($namespace)"
}

def "k bash" [pod] {
  let pod = k get po -o name | lines | find $pod | first
  k exec -it $pod -- bash
}

def "k sh" [pod] {
  let pod = k get po -o name | lines | find $pod | first
  k exec -it $pod -- sh
}

def "k run" [pod, ...args] {
  let pod = k get po -o name | lines | find $pod | first
  k exec -it $pod -- $args
}

def "k uc" [context] {
  k config use-context $context
}

def "k ga" [...args] {
  k get all $args
}

def liquidctl-colors [color] {
  liquidctl --serial 1305006473291217 set led1 color clear
  liquidctl --serial 1305006473291217 set led2 color clear
  liquidctl --serial 1805006373291A10 set led1 color clear
  liquidctl --serial 1805006373291A10 set led2 color clear
  liquidctl --serial 1305006473291217 set led1 color fixed $color
  liquidctl --serial 1305006473291217 set led2 color fixed $color
  liquidctl --serial 1805006373291A10 set led1 color fixed $color
  liquidctl --serial 1805006373291A10 set led2 color fixed $color
}

def wezterm-set-user-var [key, value] {
  printf '\033]1337;SetUserVar=%s=%s\007' $key ($value | base64 -w0)
}

# A command to handle date and time
def "dt unix" [
  --nano (-n)               # If set, the given timestamp is in nanoseconds
  --zone (-z) = "l"         # The timezone to use (u)tc, (l)ocal
  timestamp: string         # The unix timestamp to convert, defaults to now
  ] {
  let timestamp = if ($nano == true) {
    $timestamp
  } else {
    ($timestamp | into int) * 1_000_000_000
  }

  $"($timestamp)" | into datetime -z $zone | format date "%+"
}

def "update-mirrors" [] {
	rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist
}

def tx [] {
  $env.SIMPLE_PROMPT = true
  tmux new-session -d -c ~/dev/dotfiles -s • -n "nv"
  tmux send-keys -t •:0 "v ." C-m
  tmux new-window -d -c ~/dev/dotfiles -t •:1 -n "nu"

  tmux new-session -d -c ~ -s 🏠 -n "~"
  tmux new-window -d -c ~/dev -t 🏠:1 -n "dev"

  tmux attach -t 🏠
}
