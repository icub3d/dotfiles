# System Maintenance Module

# Ensure a group exists and the current user is a member.
export def "add-group" [group: string] {
    sudo groupadd -f $group
    sudo usermod -aG $group (whoami | str trim)
}

# Enable and start a system service.
export def "add-service" [name: string] {
    sudo systemctl enable --now $"($name).service"
}

# Enable and start a user service.
export def "add-user-service" [name: string] {
    systemctl --user enable --now $"($name).service"
}

# Ensure $target is a symlink pointing at $src. Replaces wrong targets.
export def "ensure-link" [src: path, target: path] {
    let src_real = ($src | path expand)
    let current = if ($target | path exists) {
        try { $target | path expand } catch { "" }
    } else { "" }
    if $current == $src_real {
        print $"  ✅ ($target) already linked"
    } else {
        if ($target | path exists) { rm -rf $target }
        mkdir ($target | path dirname)
        ln -s $src_real $target
        print $"  ✅ Linked ($target) → ($src_real)"
    }
}

# Appendix of dotfiles installation logic
export def dotfiles [] {
  let dotfiles_root = ($nu.home-dir | path join "dev/dotfiles")
  cd $dotfiles_root

  let config_dir = ($nu.home-dir | path join ".config")
  mkdir $config_dir
  let nvim_link = ($config_dir | path join "nvim")
  if not ($nvim_link | path exists) { ln -s ($dotfiles_root | path join "nvim") $nvim_link }

  # gnupg
  let gnupg_dir = ($nu.home-dir | path join ".gnupg")
  mkdir $gnupg_dir
  for f in ["gpg.conf", "gpg-agent.conf"] {
    let dest = ($gnupg_dir | path join $f)
    if not ($dest | path exists) {
      cp ($dotfiles_root | path join "helpers" $f) $dest
      chmod 600 $dest
    }
  }

  # make symlinks for all the files
  let src_root = ($dotfiles_root | path join "dotfiles")
  ls -a ($src_root | path join "**/*")
    | where type == "file"
    | get name
    | each { |n|
      let rel = ($n | str replace $"($src_root)/" "")
      let target = ($nu.home-dir | path join $rel)
      mkdir ($target | path dirname)
      if not ($target | path exists) { ln -s $n $target }
    }
}

# Update the entire system (Arch Linux)
export def update-system [] {
  dotfiles

  # Configure Pacman (only run sed if the toggles are still commented out)
  let pacman_conf = (open /etc/pacman.conf)
  if ($pacman_conf | str contains "#Color") {
    sudo /usr/bin/sed -i -e 's/#Color/Color/g' /etc/pacman.conf
  }
  if ($pacman_conf | str contains "#ParallelDownloads = 5") {
    sudo /usr/bin/sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
  }

  if not ("/usr/bin/paru" | path exists) {
    print "Installing paru..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd ($nu.home-dir | path join "dev/dotfiles")
  }

  let selected_packages = (
    open .selected_packages
    | str trim
    | split row -r '\s+'
    | where { |p| $p | is-not-empty }
  )
  let installed = (pacman -Q | lines | parse "{package} {version}" | get package)
  let packages = (
    $selected_packages
    | each { |p| open $"packages/pacman/($p)" | lines }
    | flatten
    | where { |p| $p | is-not-empty }
  )
  let needed = ($packages | where { |p| not ($p in $installed) })

  print $"📦 Installing/upgrading ($packages | length) packages \(($needed | length) new)..."
  if ($needed | is-not-empty) {
    paru -Syu --needed --noconfirm ...$needed
  } else {
    paru -Syu --noconfirm
  }

  # Run post-install scripts only for packages that have one. Each script runs
  # in a subshell with the helpers from this module pre-loaded so it can call
  # add-service/add-group/etc.
  let post_install_scripts = (
    $packages
    | each { |p| $"packages/post-install/($p).nu" }
    | where { |s| $s | path exists }
  )
  let helpers = ($nu.default-config-dir | path join "modules/system.nu")
  print $"🔧 Running ($post_install_scripts | length) post-install scripts..."
  for script in $post_install_scripts {
    print $"  ↳ ($script)"
    nu -c $"use ($helpers) *; source ($script | path expand)"
  }
}
