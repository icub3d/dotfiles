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
    },
    {
      name: "nvim_current_dir",
      modifier: control,
      keycode: char_w,
      mode: [vi_insert, vi_normal],
      event: {
        send: ExecuteHostCommand,
        cmd: "nvim ."
      }
    },
    {
      name: "yazi_current_dir",
      modifier: alt,
      keycode: char_f,
      mode: [vi_insert, vi_normal],
      event: {
        send: ExecuteHostCommand,
        cmd: "yazi ."
      }
    },
    {
      name: "job_unfreeze",
      modifier: control,
      keycode: char_z,
      mode: [vi_insert, vi_normal, emacs],
      event: {
        send: ExecuteHostCommand,
        cmd: "job unfreeze"
      }
    },
    {
      name: "run_gemini",
      modifier: alt,
      keycode: char_g,
      mode: [vi_insert, vi_normal, emacs],
      event: {
        send: ExecuteHostCommand,
        cmd: "gemini"
      }
    }
  ]
}

# aliases
alias fg = job unfreeze
alias bench = hyperfine
alias cat = bat
alias c = cargo
alias d = docker
alias dc = docker compose
alias du = dust
alias p = podman
alias pc = podman compose
alias diff = delta
alias g = git
alias gg = lazygit
alias grep = rg
alias n = niri
alias hexdump = hx
alias iftop = bandwhich
alias img = kitten icat
alias less = bat
alias m = make
alias mk = minikube
alias objdump = bingrep
alias ping = prettyping
alias pointer = highlight-pointer -c '#ff6188' -p '#a9dc76' -r 10
alias rg = rg --hidden --glob '!.git'
alias v = nvim
alias w = viddy

def "time" [...args] {
  timeit { nu -c ($args | str join ' ') }
}

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

# Parse INI configuration files
def "parse ini" [ path?: path ] {
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
    cat $path | lines
  }

  $content
  | where $it != "" and not ($it | str starts-with "#")  # ignore blanks and comments
  | reduce -f {} {|line, acc|
      if $line =~ '^\[.*\]$' {
          let section = ($line | str replace -a -r '\[|\]' '')
          $acc | upsert $section {} | upsert current_section $section
      } else if $line =~ ':' {
          let parts = ($line | split column -n 2 -r '[:=]')
          let key = ($parts | get 0.column0 | str trim)
          let val = ($parts | get 0.column1 | str trim)
          let section = ($acc.current_section | into string)
          mut out = ($acc | reject current_section)
          let current = (if ($out | get $section | is-empty) { {} } else { $out | get $section })
          $out | upsert $section ($current | upsert $key $val) | upsert current_section $section
      } else {
          $acc
      }
  }
  | reject -o current_section
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
  }


  # check to see if the .selected_packages file is there.
  cd ~/dev/dotfiles
  if (not (".selected_packages" | path exists)) {
    let full_list = (ls packages/pacman/ | each {|f| $f.name | str replace packages/pacman/ "" } | sort | uniq)
    print $"($full_list)"
    let selected = input $"packages to install> "
    if ($selected != "") {
      $selected | save -f .selected_packages
    } else {
      print "no packages selected"
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
  } | flatten | where $it != ""
  print $"packages: ($packages)"
  let needed = $packages | where { |p| not ($p in $installed) }

  print $"missing packages: ($needed)"

  # install packages
  do -i {
    print $"yes | paru -Syu --needed --noconfirm ...($needed)"
    yes | paru -Syu --needed --noconfirm ...$needed
  }
  
  print "Starting package installers"
  # run the post install scripts
  for package in $packages {
    let script_path = $"packages/post-install/($package).nu"
    if ($script_path | path exists) {
      do -i {
        print $"post install ($package)"
        nu -c $"source $nu.env-path; source $nu.config-path; source ($script_path)"
      }
    }
  }

  for package in $selected_packages {
    let script_path = $"packages/post-install/($package).nu"
    if ($script_path | path exists) {
      do -i {
        print $"post install ($package)"
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
  sudo liquidctl initialize all
  sudo liquidctl set --serial 1305006473291217 fan1 speed 20 600 30 600 40 1000 50 1000 60 1000 --temperature-sensor 2
  sudo liquidctl set --serial 1305006473291217 led1 color fixed a9dc76
  sudo liquidctl set --serial 1305006473291217 led2 color fixed a9dc76
  sudo liquidctl set --serial 1805006373291A10 fan1 speed 20 500 30 800 35 1000 38 1200 40 1500 --temperature-sensor 1
  sudo liquidctl set --serial 1805006373291A10 fan2 speed 20 400 40 400 50 400 60 400 70 400 --temperature-sensor 1
  sudo liquidctl set --serial 1805006373291A10 fan3 speed 20 500 30 800 35 1000 38 1200 40 1500 --temperature-sensor 1
  sudo liquidctl set --serial 1805006373291A10 fan4 speed 20 500 30 800 35 1000 38 1200 40 1500 --temperature-sensor 1
  sudo liquidctl set --serial 1805006373291A10 fan5 speed 20 500 30 800 35 1000 38 1200 40 1500 --temperature-sensor 1
  sudo liquidctl set --serial 1805006373291A10 fan6 speed 20 1500 30 2000 40 2500 50 3000 55 3500 60 4800 --temperature-sensor 1
  sudo liquidctl set --serial 1805006373291A10 led1 color fixed a9dc76
  sudo liquidctl set --serial 1805006373291A10 led2 color fixed a9dc76
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
  bankctl -u $mongo_uri -d bank add 1000 anna.l.marshian@gmail.com allowance
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

  # download the ISO
  http get $iso | save -f archlinux-x86_64.iso

  # download the signature
  http get $sig | save -f archlinux-x86_64.iso.sig

  # verify the signature
  let sig_check = do { gpg -q --keyserver-options auto-key-retrieve --verify archlinux-x86_64.iso.sig archlinux-x86_64.iso } | complete
  if ($sig_check.exit_code != 0) {
	echo "signature verification failed"
  }
}

def get-catppucin-wallpapers [] {
  mkdir ~/Pictures/Wallpapers
  let images = [
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/misc/rainbow.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/misc/virus.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/misc/cat-sound.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/os/arch-black-4k.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/waves/cat-waves.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/landscapes/forrest.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/landscapes/shaded_landscape.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/mandelbrot/mandelbrot_full_green.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/mandelbrot/mandelbrot_full_sky.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/mandelbrot/mandelbrot_side_green.png",
  "https://github.com/zhichaoh/catppuccin-wallpapers/blob/1023077979591cdeca76aae94e0359da1707a60e/mandelbrot/mandelbrot_side_sky.png",

  ];
  for image in $images {
    http get $"($image)?raw=true" | save -f ($nu.home-path | path join "Pictures" | path join "Wallpapers" | path join ($image | path split | last))
  }
}

def get-marshian-images [] {
  mkdir ~/Pictures/Wallpapers
  let base = "https://logo.marsh.gg/dist/"
  let images = [
    "marshians-green/marshians-green-background-3k.png",
    "marshians-pink/marshians-pink-background-3k.png",
    "marshians-orange/marshians-orange-background-3k.png",
    "marshians-yellow/marshians-yellow-background-3k.png",
    "marshians-blue/marshians-blue-background-3k.png",
    "marshians-violet/marshians-violet-background-3k.png",
  ];
  for image in $images {
    http get $"($base)($image)" | save -f ($nu.home-path | path join "Pictures" | path join "Wallpapers" | path join ($image | path split | last))
  }
  http get "https://img.marsh.gg/avatar.png" | save -f ($nu.home-path | path join "Pictures/avatar.png")
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

# Parse a stage file that came from multi-stage-timer.
def parse-stage-file [file: string] {
    let file = ($file | path expand)

    # Validate file exists
    if not ($file | path exists) {
        print-error $"JSON file not found: '($file)'"
        return
    }

    # Parse JSON
    let data = (open --raw $file | from json)

    # Get stage times (fall back to empty if missing)
    let stages = ($data | get stageTimes | default [])

    # Sort stages by startMs to ensure order
    let stages = ($stages | sort-by startMs)

    if ($stages | is-empty) {
        print-info "No 'stageTimes' found in JSON."
        return
    }

    # Print timestamp lines, converting startMs (milliseconds) to either 'M:SS' or 'H:MM:SS'.
    for $st in $stages {
        let start_ms = ($st | get startMs | default 0)
        let total_secs = ($start_ms / 1000 | into int)
        let hours = (($total_secs / 3600) | into int)
        let mins = ((($total_secs mod 3600) / 60) | into int)
        let secs = (($total_secs mod 60) | into int)

        let time_str = (
            if $hours > 0 {
                # H:MM:SS — zero-pad minutes and seconds to 2 digits
                if $mins < 10 {
                    if $secs < 10 { $"($hours):0($mins):0($secs)" } else { $"($hours):0($mins):($secs)" }
                } else {
                    if $secs < 10 { $"($hours):($mins):0($secs)" } else { $"($hours):($mins):($secs)" }
                }
            } else {
                # M:SS — seconds zero-padded
                if $secs < 10 { $"($mins):0($secs)" } else { $"($mins):($secs)" }
            }
        )

        let name = ($st | get stageName | default "Unnamed Stage")
        print $"($time_str) ($name)"
    }
}

# Upload a file to a GitHub Gist using the gh CLI and returns the gist id.
def "upload-gist" [
  description: string, # The description to use for the gist.
  ...files: string # paths to file
] {

  let files = ($files | each {|f| ($f | path expand)});

  for file in $files {
    if not ($file | path exists) {
        print-error ("file not found: " ++ $file)
        return
    }
  }

  let cmd = (["gh" "gist" "create" "--public" "--desc" $description] | append $files);
  let result = do -i { ^$cmd }
  if ($result | describe) == 'string' {
      print-info "Gist uploaded successfully!"
      $result
  } else if ($result.exit_code? | default 1) == 0 {
      print-info "Gist uploaded successfully!"
      $result.stdout? | default ""
  } else {
      print-error "Failed to upload Gist."
      $result.stderr? | default $result
  }
}

# Generate a YouTube description that will have a stage timer and gist.
def youtube-description [
  problem_url: string, # The URL of the problem being solved.
  stage_file: string, # The path to the stage file.
  description: string, # The description to use for the gist.
  ...files: string # paths to files for gist.
] {
  let solution_url = (upload-gist $description ...$files);
  
  # Print header for description
  print "[TODO]"
  print ""
  print $"Problem: ($problem_url)"
  print $"Solution: ($solution_url)"
  print ""

  parse-stage-file $stage_file
}

# Shorten an mkv file to 25 seconds and save it to path-short.mkv.
export def shorten-video [
    file: path # The path to the input MKV file.
] {
    # --- Configuration ---
    let target_duration = 25.0
    let normal_speed_duration = 10.0
    let sped_up_duration = 15.0
    
    # 1. Check if the file exists
    let file_path = ($file | path expand)
    if not ($file_path | path exists) {
        print $"🚨 Error: File not found: ($file_path)"
        return
    }

    # 2. Get original duration using ffprobe
    # We use a subexpression to execute ffprobe and capture its output
    let duration_output = (
        ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $file_path | lines | get 0
    )

    # Check if ffprobe returned a valid duration string
    if ($duration_output | is-empty) {
        print $"🚨 Error: Could not determine duration for ($file_path). Is ffprobe installed and is the file valid?"
        return
    }
    
    # Convert the duration output (string) to a number.
    # FIX: Changed 'str to-float' to 'into float' to resolve parser error.
    let original_duration = ($duration_output | into float)

    # 3. Determine output filename (e.g., video.mkv -> video-1m.mkv)
    # FIX: Using 'path parse' to safely extract stem and extension in one go.
    # This avoids potential parser issues with individual 'path' subcommands.
    let path_parts = ($file_path | path parse)
    let output_path = ($path_parts.parent | path join $"($path_parts.stem)-short.($path_parts.extension)")

    print $"\n🎬 Processing File: ($file_path)"
    # We round the duration for display purposes here
    print $"⏳ Original Duration: ($original_duration | math round --precision 3) seconds"
    print $"💾 Target Output: ($output_path)"

    # 4. Conditional Logic: Copy or Process
    if ($original_duration) <= $target_duration {
        # If already short enough, just copy the file
        print $"Duration is less than or equal to ($target_duration)s. Simply copying the file to the new name."
        cp $file_path $output_path
        print "✅ File copied successfully."
    } else {
        # Calculate the duration of the first part (everything except last 10 seconds)
        let first_part_original_duration = ($original_duration - $normal_speed_duration)
        
        # Calculate speed factor for the first part to fit into 15 seconds
        let speed_factor = ($first_part_original_duration / $sped_up_duration)
        
        # Calculate the start time for the second part (normal speed)
        let second_part_start = $first_part_original_duration

        # Handle the audio speed factor. The 'atempo' filter has a maximum value of 100.
        # If the required speedup is > 100, we must chain multiple atempo filters.
        let atempo_filter = if $speed_factor > 100.0 {
            # Example: If F=150, chain: atempo=100.0,atempo=1.5
            let first_factor = 100.0
            let remainder_factor = ($speed_factor / $first_factor)
            $"atempo=($first_factor),atempo=($remainder_factor)"
        } else {
            $"atempo=($speed_factor)"
        }

        let pts_factor = (1.0 / $speed_factor)
        
        print $"🚀 First Part: ($first_part_original_duration | math round --precision 3)s → ($sped_up_duration)s \(speed factor: ($speed_factor | math round --precision 3))"
        print $"🎯 Second Part: Last ($normal_speed_duration)s at normal speed"
        print $"⚙️ Total Output Duration: ($target_duration)s"

        # Construct the complex filter:
        # 1. Split video into two parts: [0 to second_part_start] and [second_part_start to end]
        # 2. Speed up the first part
        # 3. Keep the second part at normal speed
        # 4. Concatenate both parts
        let filter_complex = $"[0:v]trim=end=($second_part_start),setpts=($pts_factor)*PTS[v1];[0:a]atrim=end=($second_part_start),($atempo_filter),asetpts=PTS-STARTPTS[a1];[0:v]trim=start=($second_part_start),setpts=PTS-STARTPTS[v2];[0:a]atrim=start=($second_part_start),asetpts=PTS-STARTPTS[a2];[v1][a1][v2][a2]concat=n=2:v=1:a=1[outv][outa]"

        # Construct and execute the ffmpeg command
        ffmpeg -hide_banner -loglevel error -i $file_path -filter_complex $filter_complex -map "[outv]" -map "[outa]" -c:v libx264 -preset veryfast -crf 23 -c:a aac -b:a 192k $output_path -y
        
        print "✅ FFmpeg processing complete. New 25-second file generated (15s sped up + 10s normal)."
    }
}

# A helper function that will put an image in front of a video and add a random
# audio from the given path.
def make-kattis-short [
    image_path: path, # image path
    video_path: path, # video path
    audio_folder: path,  # folder from which to randomly pick audio
    output_name: path, # where to save the file
] {
    print "🔍 Analyzing resources..."

    # 1. PICK RANDOM AUDIO
    # valid extensions: mp3, wav, flac, m4a, aac, ogg
    let audio_candidates = (
        ls $audio_folder 
        | where name =~ '(?i)\.(mp3|wav|flac|m4a|aac|ogg)$'
    )

    if ($audio_candidates | is-empty) {
        error make {msg: $"❌ No audio files found in ($audio_folder)!"}
    }

    # Shuffle the list and take the first one
    let selected_audio = ($audio_candidates | shuffle | first).name
    print $"🎵 Selected Track: ($selected_audio)"

    # 2. PROBE THE VIDEO
    let metadata = (
        ffprobe -v error 
        -select_streams v:0 
        -show_entries stream=width,height,r_frame_rate 
        -show_entries format=duration 
        -of json 
        $video_path 
        | from json
    )

    let width = $metadata.streams.0.width
    let height = $metadata.streams.0.height
    let fps_string = $metadata.streams.0.r_frame_rate
    let video_duration = ($metadata.format.duration | into float)
    
    # Calculate FPS
    let raw_fps = ($fps_string | split row "/" | into int | reduce { |it, acc| $it / $acc })
    let fps = if $raw_fps < 1.0 { 30 } else { $raw_fps }

    print $"🎥 Detected: ($width)x($height) @ ($fps | math round --precision 2) fps"
    print $"⏱️ Duration: ($video_duration | math round --precision 2)s"
    print "🚀 Starting render..."

    # 3. CONFIGURATION
    let img_len = 2.0
    let vid_fade_len = 0.5
    let vid_offset = ($img_len - $vid_fade_len)
    let total_len = ($video_duration + $img_len - $vid_fade_len)
    let aud_fade_len = 2.0
    let aud_fade_start = ($total_len - $aud_fade_len)

    # 4. FILTER CONSTRUCTION
    let pad_math = '(ow-iw)/2:(oh-ih)/2'

    # Note: fps=($fps) and settb=1/($fps) are CRITICAL for stability
    let filter = $"[0:v]scale=($width):($height):force_original_aspect_ratio=decrease,pad=($width):($height):($pad_math),setsar=1,format=yuv420p,fps=($fps),settb=1/($fps)[img];[1:v]format=yuv420p,setsar=1,fps=($fps),settb=1/($fps)[vid];[img][vid]xfade=transition=fade:duration=($vid_fade_len):offset=($vid_offset)[v];[2:a]afade=t=out:st=($aud_fade_start):d=($aud_fade_len)[a]"

    # 5. RUN FFMPEG
    # We use $selected_audio as the 3rd input (-i)
    ffmpeg -y -hide_banner -loglevel error -stats -loop 1 -t $img_len -r $fps -i $image_path -i $video_path -i $selected_audio -filter_complex $filter -map "[v]" -map "[a]" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 192k -shortest $output_name

    print $"\n✅ Done! Saved to: ($output_name)"
}

# Remove audio from a video file and save with -no-sound.mkv suffix
def make-kattis-short-no-sound [
    file: path, # video file to remove audio from
] {
    let file_path = ($file | path expand)
    
    # Check if the file exists
    if not ($file_path | path exists) {
        print $"🚨 Error: File not found: ($file_path)"
        return
    }
    
    # Generate output filename: file.mkv -> file-no-sound.mkv
    let path_parts = ($file_path | path parse)
    let output_path = ($path_parts.parent | path join $"($path_parts.stem)-no-sound.($path_parts.extension)")
    
    print $"🔇 Removing audio from: ($file_path)"
    print $"💾 Saving to: ($output_path)"
    
    # Run ffmpeg to copy video without audio
    ffmpeg -y -hide_banner -loglevel error -stats -i $file_path -c:v copy -an $output_path
    
    print $"\n✅ Done! Audio removed and saved to: ($output_path)"
}

# Competitive Programming Helper Functions

# Find a Rust file based on search patterns
def "cph find-file" [...patterns: string] {
    if ($patterns | is-empty) {
        let files = (fd --type f --extension rs | lines)
        if ($files | is-empty) {
            print-error "No Rust files found"
            return null
        }
        let file = ($files | first)
        return $file
    }
    
    # Get all .rs files and filter by patterns
    let all_files = (fd --type f --extension rs | lines)
    
    # Filter files that contain all patterns (case-insensitive)
    let matching_files = ($all_files | where {|file|
        let matches_all = ($patterns | all {|pattern|
            $file | str contains -i $pattern
        })
        $matches_all
    })
    
    if ($matching_files | is-empty) {
        print-error $"No Rust files found matching: ($patterns)"
        return null
    }
    
    let file = ($matching_files | first)
    $file
}

# Get cargo package name from a file path
def "cph get-package" [file: string] {
    let file_path = ($file | path expand)
    let dir = ($file_path | path dirname)
    
    mut current = $dir
    mut found_cargo = ""
    
    # First, find the closest Cargo.toml (package)
    loop {
        let cargo_toml = ($current | path join "Cargo.toml")
        if ($cargo_toml | path exists) {
            $found_cargo = $cargo_toml
            break
        }
        
        let parent = ($current | path dirname)
        if $parent == $current {
            break
        }
        $current = $parent
    }
    
    if ($found_cargo | is-empty) {
        return {package: null, needs_flag: false}
    }
    
    # Now check if there's a workspace Cargo.toml anywhere above
    let pkg_dir = ($found_cargo | path dirname)
    mut search_dir = ($pkg_dir | path dirname)
    
    loop {
        let potential_workspace = ($search_dir | path join "Cargo.toml")
        if ($potential_workspace | path exists) and ($potential_workspace != $found_cargo) {
            let workspace_content = (open $potential_workspace)
            if ($workspace_content | get -o workspace | is-not-empty) {
                let package_name = (open $found_cargo | get package.name)
                return {package: $package_name, needs_flag: true}
            }
        }
        
        let parent = ($search_dir | path dirname)
        if $parent == $search_dir {
            break
        }
        $search_dir = $parent
    }
    
    return {package: null, needs_flag: false}
}

# Get binary name from file path
def "cph get-bin" [file: string] {
    $file | path parse | get stem
}

# Build cargo command for a file
def "cph build-cmd" [file: string, cmd: string, ...extra_args: string] {
    let pkg_info = (cph get-package $file)
    let bin_name = (cph get-bin $file)
    
    mut cargo_cmd = ["cargo" $cmd]
    
    if $pkg_info.needs_flag {
        $cargo_cmd = ($cargo_cmd | append ["-p" $pkg_info.package])
    }
    
    $cargo_cmd = ($cargo_cmd | append ["--bin" $bin_name])
    $cargo_cmd = ($cargo_cmd | append $extra_args)
    
    $cargo_cmd
}

# Run a competitive programming solution with summary
def "cph run-with-summary" [file: string] {
    let bin_name = (cph get-bin $file)
    
    # Get workspace info if in a workspace
    let pkg_info = (cph get-package $file)
    let workspace_name = if $pkg_info.needs_flag { $pkg_info.package } else { "" }
    
    # Run tests
    let test_cmd = (cph build-cmd $file "test" "--release" "--no-fail-fast")
    let test_run = (do -i { ^$test_cmd } | complete)
    let test_lines = ($test_run.stdout | default "" | lines | where {|it| ($it | str trim | str starts-with "test ") })
    
    # Run the solution
    let run_cmd = (cph build-cmd $file "run" "--release" "-q")
    let run_output = (do -i { ^$run_cmd } | complete)
    
    # Parse output lines that match [partno] [timing] [answer]
    let part_outputs = (
        $run_output.stdout 
        | default "" 
        | lines 
        | where {|l| not ($l | is-empty)} 
        | where {|l| ($l | str starts-with "p")} 
        | each {|line|
            # Try to parse as three space-separated fields
            let parts = ($line | split row -r '\s+')
            if ($parts | length) >= 3 {
                {
                    part: ($parts | get 0),
                    time: ($parts | get 1),
                    solution: ($parts | get 2),
                }
            } else {
                null
            }
        }
        | compact
    )
    
    if ($part_outputs | is-empty) {
        # No valid output, just print what we got
        print $run_output.stdout
        return
    }
    
    # Check if helper.nu exists for getting targets
    let has_helper = ("helper.nu" | path exists)
    
    # Build results table
    mut results = []
    for part_output in $part_outputs {
        let part_no = $part_output.part
        
        # Find matching tests (test_[partno].*)
        let test_pattern = $"test_($part_no)"
        let part_test_lines = ($test_lines | where {|it| $it | str contains $test_pattern })
        let failed_tests = ($part_test_lines | where {|it| not ($it | str contains "ok") })
        
        let test_status = if ($part_test_lines | is-empty) {
            "❓" # No test for this part
        } else if ($failed_tests | is-empty) {
            "✅" # All tests passed
        } else {
            "❌" # Some tests failed
        }
        
        # Get target answer from helper if available
        mut target = ""
        mut answer_status = "🔄"
        
        if $has_helper {
            let helper_args = if ($workspace_name | is-empty) {
                [$bin_name $part_no]
            } else {
                [$workspace_name $bin_name $part_no]
            }
            
            let target_result = (do -i { 
                nu helper.nu get-target ...$helper_args 
            } | complete)
            
            if $target_result.exit_code == 0 {
                $target = ($target_result.stdout | str trim)
                
                if ($target | is-empty) {
                    $answer_status = "🔄"
                } else if $part_output.solution == $target {
                    $answer_status = "✅"
                } else {
                    $answer_status = "❌"
                }
            }
        }
        
        $results = ($results | append {
            part: $part_no,
            test_status: $test_status,
            answer_status: $answer_status,
            time: $part_output.time,
            solution: $part_output.solution,
            target: $target,
        })
    }
    
    if not ($results | is-empty) {
        $results | rename "🧩" "🧪" "🚦" "⏰" "💡" "🎯" | table -i false | print
        print ""
    }
}

# Run a competitive programming solution
export def "cph run" [...patterns: string] {
    let file = (cph find-file ...$patterns)
    if $file == null { return }
    
    let cmd = (cph build-cmd $file "run" "--release" "-q")
    ^$cmd
}

export alias "cph r" = cph run

# Test a competitive programming solution
export def "cph test" [...patterns: string] {
    let file = (cph find-file ...$patterns)
    if $file == null { return }
    
    let cmd = (cph build-cmd $file "test" "--release" "--no-fail-fast" "--" "--no-caputre")
    ^$cmd
}

export alias "cph t" = cph test

# Watch and run a competitive programming solution
export def "cph watch" [
    ...patterns: string,
    --test, # Run tests instead of the solution
] {
    let file = (cph find-file ...$patterns)
    if $file == null { return }
    
    reset-terminal
    if $test {
        cph test ...$patterns
    } else {
        try {
            cph run-with-summary $file
        } catch { |err|
            print-error $"Compilation failed: ($err.msg)"
            print "🔄 Watching for changes..."
        }
    }
    
    try {
        watch --quiet . --glob=**/*.rs {||
            reset-terminal
            if $test {
                cph test ...$patterns
            } else {
                try {
                    cph run-with-summary $file
                } catch { |err|
                    print-error $"Compilation failed: ($err.msg)"
                    print "🔄 Watching for changes..."
                }
            }
        }
    } catch { null }
}

export alias "cph w" = cph watch

# Debug a competitive programming solution (tests with output + run)
export def "cph debug" [...patterns: string] {
    let file = (cph find-file ...$patterns)
    if $file == null { return }
    
    reset-terminal
    
    print "🧪 Tests 🧪"
    let test_cmd = (cph build-cmd $file "test" "--release" "--no-fail-fast" "--" "--nocapture")
    try { ^$test_cmd out+err>| sed -E -e '/^\s*(Running|Finished|Running)/d' } catch { null }
    
    print "\n🚀 Solution 🚀"
    let run_cmd = (cph build-cmd $file "run" "--release" "-q")
    try { ^$run_cmd } catch { null }
}

export alias "cph d" = cph debug

# Watch and debug a competitive programming solution
export def "cph watch-debug" [...patterns: string] {
    let file = (cph find-file ...$patterns)
    if $file == null { return }
    
    cph debug ...$patterns
    
    try {
        watch --quiet . --glob=**/*.rs {||
            cph debug ...$patterns
        }
    } catch { null }
}

export alias "cph wd" = cph watch-debug

# Call a helper script with arguments
export def "cph helper" [...args: string] {
    let helper_script = "helper.nu"
    
    if not ($helper_script | path exists) {
        print-error "No helper.nu script found in current directory"
        return
    }
    
    try {
        nu $helper_script ...$args
    } catch {
      null
    }
}

export alias "cph h" = cph helper

# Create a new competitive programming solution from template
export def "cph new" [...args: string] {
    # Find template.rs
    let template_files = (fd --type f --glob "**/template.rs" | lines)
    
    if ($template_files | is-empty) {
        print-error "No template.rs file found in current directory tree"
        return
    }
    
    let template = ($template_files | first)
    print-info $"Using template: ($template)"
    
    if ($args | length) == 0 {
        print-error "Usage: cph new <name> or cph new <workspace> <name>"
        return
    } else if ($args | length) == 1 {
        # Single argument: create in src/bin
        let name = ($args | get 0)
        let target_dir = "src/bin"
        
        if not ($target_dir | path exists) {
            print-error $"Directory ($target_dir) not found"
            return
        }
        
        let target_file = ($target_dir | path join $"($name).rs")
        
        if ($target_file | path exists) {
            print-error $"File ($target_file) already exists"
            return
        }
        
        # Read template, replace placeholders, and save
        let content = (open $template | str replace -a "[NAME]" $name | str replace -a "[WORKSPACE]" "")
        $content | save $target_file
        print-info $"Created: ($target_file)"
        
        # Run helper get-input if helper.nu exists
        if ("helper.nu" | path exists) {
            cph helper get-input $name
        }
        
    } else if ($args | length) == 2 {
        # Two arguments: find workspace and create in its src/bin
        let workspace_pattern = ($args | get 0)
        let name = ($args | get 1)
        
        # Find directories matching the workspace pattern
        let workspace_dirs = (fd --type d --glob $"**/*($workspace_pattern)*" | lines | where {|d| 
            ($d | path join "src" | path join "bin" | path exists)
        })
        
        if ($workspace_dirs | is-empty) {
            print-error $"No workspace found matching '($workspace_pattern)' with src/bin directory"
            return
        }
        
        let workspace = ($workspace_dirs | first)
        let workspace_name = ($workspace | path basename)
        print-info $"Using workspace: ($workspace)"
        
        let target_dir = ($workspace | path join "src" | path join "bin")
        let target_file = ($target_dir | path join $"($name).rs")
        
        if ($target_file | path exists) {
            print-error $"File ($target_file) already exists"
            return
        }
        
        # Read template, replace placeholders, and save
        let content = (open $template | str replace -a "[NAME]" $name | str replace -a "[WORKSPACE]" $workspace_name)
        $content | save $target_file
        print-info $"Created: ($target_file)"
        
        # Run helper get-input if helper.nu exists
        if ("helper.nu" | path exists) {
            cph helper get-input $workspace_name $name
        }
    } else {
        print-error "Usage: cph new <name> or cph new <workspace> <name>"
        return
    }
}

export alias "cph n" = cph new


