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
];

# Load the environment from the system profiles.
bash -c $"[ -f /etc/profile ] && source /etc/profile; [ -f ($env.HOME)/.profile ] && source ($env.HOME)/.profile; env" | lines | parse "{n}={v}" | filter { |x| (not ($x.n in $env)) or $x.v != ($env | get $x.n) } | filter {|x| not ($x.n in ["_", "LAST_EXIT_CODE", "DIRS_POSITION"])} | transpose --header-row | into record | load-env

# Add our custom paths to the PATH variable and clean it up
$env.PATH = ($env.PATH | split row (char esep) | prepend $paths | uniq);

# General config
$env.config = {
  show_banner: false,
  edit_mode: "vi",
  history: {
    max_size: 100000,
  }
}

# aliases
alias bench = hyperfine
alias cat = bat
alias d = docker
alias dc = docker compose
alias diff = delta
alias e = emacsclient --create-frame --alternate-editor="" -nw
alias em = emacs -nw
alias g = git
alias gg = lazygit
alias grep = rg
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
alias rme = /usr/bin/find -ih '~$' -x rm {} \;
alias v = nvim
alias w = /usr/bin/watch

#########################################################
# functions
#########################################################

def "lla" [path = "."] {
  ls -la $path | grid -c
}

def "la" [path = "."] {
  ls -a $path | grid -c
}

def "ll" [path = "."] {
  ls -l $path | grid -c
}

def "l" [path = "."] {
  ls $path | grid -c
}

def missing-packages [] {
  let installed = (pacman -Q | lines | parse "{package} {version}" | get package)
  let selected_packages = (open ~/dev/dotfiles/.selected_packages | split words)
  let missing = $selected_packages | filter { |p| not ($p in $installed) }
  let packages = $selected_packages | each {|p|
    let package_path = $"packages/pacman/($p)"
    open $package_path | lines
  } | flatten | filter { |p| not ($p in $installed) }
}

def update-system [] {
  dotfiles
  cd ~/dev/dotfiles
  let package_location = "pacman"

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
  let needed = $packages | filter { |p| not ($p in $installed) }

  echo $"missing packages: ($needed)"

  # install packages
  do -i {
    yes | paru -Syu --needed --noconfirm ...$needed
  }
  
  # run the post install scripts
  for package in $packages {
    let script_path = $"packages/post-install/($package).nu"
    if ($script_path | path exists) {
      nu -c $"source $nu.env-path; source $nu.config-path; source ($script_path)"
    }
  }

  for package in $selected_packages {
    let script_path = $"packages/post-install/($package).nu"
    if ($script_path | path exists) {
      nu -c $"source $nu.env-path; source $nu.config-path; source ($script_path)"
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
     find -v "fish" | # TODO: remove this once we no longer need fish
     each {|f| mkdir $f}
  mkdir ~/.ssh
  chmod 700 ~/.ssh
  chmod 700 ~/.gnupg

  # make symlinks for all the files
  let paths = ls -a ~/dev/dotfiles/dotfiles/**/* | 
    filter {|p| $p.type == "file"} | 
    get name | 
    find -v "fish" | # TODO: remove this once we no longer need fish
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
  let sha512 = (http get https://files.marsh.gg/cli-tools.($env.ARCH).zip.sha512)
  let existing_path = ($nu.home-path | path join ".config/cli-tools/sha512")
  if ($existing_path | path exists) {
    let existing = (cat $existing_path)
    if ($existing == $sha512) {
      echo "cli-tools are up to date"
      return
    }
  }

  $sha512 | save -f $existing_path
  http get https://files.marsh.gg/cli-tools.($env.ARCH).zip | save -f cli-tools.zip
  unzip -o cli-tools.zip -d ($nu.home-path | path join "bin") out> /dev/null
  rm cli-tools.zip
}

def strongbox [] {
  $env.gdk_scale = 2
  java -jar ~/dev/strongbox.jar
}

def smoke-test-ligatures [] {
  echo "normal"
  echo $"(ansi attr_bold)bold(ansi reset)"
  echo $"(ansi attr_italic)italic(ansi reset)"
  echo $"(ansi attr_bold)(ansi attr_italic)bold italic(ansi reset)"
  echo $"(ansi attr_underline)underline(ansi reset)"
  echo "== === !== >= <= =>"
  echo "契          勒 鈴 "
}

def scan-help [path] {
  ls $path | each {|file|
    xdg-open $file.name
    let base = $file.name | path basename
    let name = input $"name ($base)> "
    let name = if ($name == "") {
      $file.name
    } else {
      $name 
    }
    let name = ($path | path join ([$name, '.pdf'] | str join))
    mv $file.name $name
    gdrive files upload --parent "1e4LApZXcXz3FamcLofLOmW9Ixnd-bAlU" $name
  }
  xdg-open $path
}

def monokai [] {
  let colors = [
    {"bg": "#19181a", "fg": "#fcfcfa"},
    {"bg": "#221f22", "fg": "#fcfcfa"},
    {"bg": "#2d2a2e", "fg": "#fcfcfa"},
    {"bg": "#403e41", "fg": "#fcfcfa"},
    {"bg": "#5b595c", "fg": "#fcfcfa"},
    {"bg": "#727072", "fg": "#fcfcfa"},
    {"bg": "#939293", "fg": "#fcfcfa"},
    {"bg": "#c1c0c0", "fg": "#fcfcfa"},
    {"bg": "#fcfcfa", "fg": "#2d2a2e"},
    {"bg": "#78dce8", "fg": "#fcfcfa"},
    {"bg": "#a9dc76", "fg": "#fcfcfa"},
    {"bg": "#ab9df2", "fg": "#fcfcfa"},
    {"bg": "#fc9867", "fg": "#fcfcfa"},
    {"bg": "#ff6188", "fg": "#fcfcfa"},
    {"bg": "#ffd866", "fg": "#fcfcfa"},
  ];
  for color in $colors {
    echo $"(ansi --escape $color)($color.bg)(ansi reset)"
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
  ffmpeg -i $file -vn -acodec copy ($base).aac
  whisper ($base).aac --model medium --language en
  ls $"($base)*" | each {|f|
    gdrive files upload --parent $parent $f
  }
}

def iommu [] {
  ls /sys/kernel/iommu_groups | get name | path basename | sort -n | each {|group|
    ls /sys/kernel/iommu_groups/($group)/devices | get name | path basename | each {|device|
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
  bankctl -u $mongo_uri -d bank add 1000 james.marshian@gmail.com allowance
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
  let sig_base = "https://www.archlinux.org/iso/"

  # dowlnoad the iso
  let iso_uri = (http get $base | rg -o 'archlinux-[.0-9]+-x86_64.iso' | lines | uniq | first)
  http get $"($base)($iso_uri)" | save -f archlinux-latest-x86_64.iso

  # download the signature
  let version = ($iso_uri | rg -o '[.0-9]{10}')
  http get $"($sig_base)($version)/archlinux-($version)-x86_64.iso.sig" | save -f archlinux-latest-x86_64.iso.sig

  # verify the signature
  let sig_check = do { gpg -q --keyserver-options auto-key-retrieve --verify archlinux-latest-x86_64.iso.sig archlinux-latest-x86_64.iso } | complete
  if ($sig_check.exit_code != 0) {
	echo "signature verification failed"
  }
}

def get-marshian-images [] {
  let base = "https://logo.marsh.gg/dist/"
  let images = [
	"marshians-text-green/marshians-text-green-background-2k.png",
	"marshians-text-green/marshians-text-green-background-3k.png",
	"marshians-text-green/marshians-text-green-background-4k.png",
	"marshians-text-green/marshians-text-green-400.png",
	"marshians-green/marshians-green-background-2k.png",
	"marshians-green/marshians-green-background-3k.png",
	"marshians-green/marshians-green-background-4k.png",
	"marshians-green/marshians-green-400.png",
  ];
  for image in $images {
	http get $"($base)($image)" | save -f ($nu.home-path | path join "Pictures" | path join ($image | path split | last))
  }
}

def ykf [] {
  gpgconf --reload gpg-agent
  gpgconf --kill scdaemon
  gpg-connect-agent reloadagent /bye
  sudo systemctl restart pcscd
}

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

  wezterm-set-user-var CREATE_WORKSPACE $"($name)|($folder)"
}

def wezterm-switch-workspace [] {
  wezter-set-user-var WORKSPACE_CHANGED ($in | fzf --reverse --border=rounded --prompt "workspace> ")
}
alias sw = wezterm-switch-workspace

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
  k config set-context --current --namespace=$namespace
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

def "k oti" [ns] {
  k config use-context $"aks-oti-($ns)-eastus-001"
}

def "k otvm" [ns] {
  k config use-context $"otvm-containerized-($ns)"
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
